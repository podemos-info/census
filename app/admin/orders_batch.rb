# frozen_string_literal: true

ActiveAdmin.register OrdersBatch do
  decorate_with OrdersBatchDecorator

  menu parent: I18n.t("active_admin.payments")

  actions :index, :show, :new, :create, :edit, :update

  permit_params :description, :orders_from, :orders_to

  index do
    column :description, class: :left do |orders_batch|
      link_to orders_batch.description, orders_batch
    end
    column :orders_totals_text
    column :processed_at, class: :left
    actions
  end

  action_item :process, only: :show do
    if policy(resource).charge?
      if issues_for_resource.any?
        link_to t("census.orders_batches.review_orders"), review_orders_orders_batch_path
      else
        process_text = resource.processed_at ? t("census.orders_batches.process_orders_again") : t("census.orders_batches.process_orders")
        link_to process_text,
                charge_orders_batch_path,
                method: :patch,
                data: { confirm: t("census.messages.sure_question") },
                class: :member_link
      end
    end
  end

  sidebar :orders, partial: "orders_batches/orders", only: :show
  sidebar :jobs, partial: "orders_batches/jobs", only: :show
  sidebar :versions, partial: "orders_batches/versions", only: :show

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  form decorate: true do |f|
    controller.redirect_to(orders_batches_path) && next unless f.object.orders.any?

    f.inputs do
      input :description, as: :string
      input :orders_totals_text, as: :string, input_html: { disabled: true }
      unless f.object.persisted?
        input :orders_from, as: :datepicker
        input :orders_to, as: :datepicker
      end
    end

    actions
  end

  member_action :review_orders, method: [:get, :post] do
    @pending_bics = Hash[OrdersBatchIssues.for(resource).merge(IssuesNonFixed.for).map do |issue|
      country = issue.information["country"]
      bank_code = issue.information["bank_code"]
      key = "#{country}_#{bank_code}"
      info = { country: country, bank_code: bank_code, iban: issue.information["iban"] }
      if params.dig(:pending_bics, key)
        info[:value] = params[:pending_bics][key]
        form = BicForm.new(country: country, bank_code: bank_code, bic: params[:pending_bics][key])
        Payments::SaveBic.call(form: form, admin: current_admin) do
          on(:invalid) { info[:errors] = form.errors }
          on(:error) { flash.now[:error] = t("census.messages.error_occurred") }
          on(:ok) { info[:fixed] = true }
        end
      end
      [key, info] unless info[:fixed]
    end .compact]

    if @pending_bics.any?
      @extra_body_class = "edit"
    else
      redirect_to orders_batch_path
    end
  end

  member_action :charge, method: :patch do # Fails when naming it :process
    ProcessOrdersBatchJob.perform_later(orders_batch: resource, admin: current_admin)
    flash[:notice] = t("census.orders_batches.action_message.will_be_processed")
    redirect_back fallback_location: orders_batches_path
  end

  controller do
    attr_accessor :extra_body_class

    def build_resource
      build_params = permitted_params[:orders_batch] || {}
      first_pending_order = OrdersWithoutOrdersBatch.new.merge(OrdersPending.new).first

      if first_pending_order
        build_params[:orders_from] = first_pending_order.created_at.to_date unless build_params[:orders_from]
        build_params[:orders_to] = Time.zone.today unless build_params[:orders_to]

        resource = decorator_class.new(OrdersBatchForm.from_params(build_params))
      else
        resource = OrdersBatch.new
        flash[:alert] = t("census.orders_batches.no_pending_orders")
      end
      set_resource_ivar resource

      resource
    end

    def create
      form = build_resource
      Payments::CreateOrdersBatch.call(form: form, admin: current_admin) do
        on(:invalid) { render :new }
        on(:error) do
          flash.now[:error] = t("census.messages.error_occurred")
          render :new
        end
        on(:ok) { |info| redirect_to orders_batch_path(id: info[:orders_batch].id) }
      end
    end

    def issues_for_resource
      @issues_for_resource ||= super + OrdersBatchIssues.for(resource).merge(IssuesNonFixed.for).merge(AdminIssues.for(current_admin)).decorate
    end
  end
end
