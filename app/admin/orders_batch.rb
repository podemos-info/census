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
    if OrdersBatchNeedsReviewOrders.for(resource).any?
      link_to t("census.orders_batches.review_orders"), review_orders_orders_batch_path
    else
      process_text = resource.processed_at ? t("census.orders_batches.process_orders_again") : t("census.orders_batches.process_orders")
      link_to process_text,
              charge_orders_batch_path,
              method: :patch,
              data: { confirm: t("census.sure_question") },
              class: :member_link
    end
  end

  sidebar :orders, partial: "orders_batches/orders", only: :show
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
    @pending_bics = Hash[OrdersBatchNeedsReviewOrders.for(resource).map do |order|
      iban = order.payment_method.iban
      iban_parts = IbanBic.parse(iban)

      bic = Bic.new(country: iban_parts[:country], bank_code: iban_parts[:bank])
      if params[:pending_bics]
        bic.bic = params[:pending_bics]["#{iban_parts[:country]}_#{iban_parts[:bank]}"].strip
        bic.save
      end
      next unless order.needs_review?(inside_batch?: true)
      [iban, bic]
    end .compact]

    redirect_to orders_batch_path unless @pending_bics.any?

    @extra_body_class = "edit"
  end

  member_action :charge, method: :patch do # Fails when calling it :process
    orders_batch = resource
    needs_review_orders = false
    Payments::ProcessOrdersBatch.call(orders_batch, current_admin) do
      on(:invalid) do
        flash[:error] = t("census.orders_batches.action_message.not_processed")
      end
      on(:review) do
        flash[:warning] = t("census.orders_batches.action_message.needs_review")
        needs_review_orders = true
      end
      on(:issues) do
        flash[:warning] = t("census.orders_batches.action_message.issues")
      end
      on(:ok) do
        flash[:notice] = t("census.orders_batches.action_message.processed")
      end
    end

    if needs_review_orders
      redirect_to review_orders_orders_batch_path
    else
      redirect_back fallback_location: orders_batches_path
    end
  end

  controller do
    attr_accessor :extra_body_class

    def build_resource
      build_params = permitted_params[:orders_batch] || {}
      first_pending_order = OrdersWithoutOrdersBatch.new.merge(OrdersPending.new).first

      if first_pending_order
        build_params[:orders_from] = first_pending_order.created_at.to_date unless build_params[:orders_from]
        build_params[:orders_to] = Date.today unless build_params[:orders_to]

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
      Payments::CreateOrdersBatch.call(form) do
        on(:invalid) { render :new }
        on(:ok) { |orders_batch| redirect_to orders_batch_path(id: orders_batch.id) }
      end
    end
  end
end
