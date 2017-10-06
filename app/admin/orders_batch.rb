# frozen_string_literal: true

ActiveAdmin.register OrdersBatch do
  decorate_with OrdersBatchDecorator

  menu parent: I18n.t("active_admin.payments")

  actions :index, :show, :new, :create, :edit, :update

  permit_params :description, :orders_from, :orders_to

  index do
    id_column
    column :description, class: :left
    column :orders_totals_text
    actions
  end

  action_item :process, only: :show do
    link_to t("census.orders_batches.process"), charge_orders_batch_path(orders_batch), method: :patch,
                                                                                        data: { confirm: t("census.sure_question") },
                                                                                        class: :member_link
  end

  sidebar :versions, partial: "orders_batches/versions", only: :show
  sidebar :orders, partial: "orders_batches/orders", only: :show

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  form decorate: true do |f|
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

  member_action :charge, method: :patch do # Fails when calling it :process
    orders_batch = resource
    Payments::ProcessOrdersBatch.call(orders_batch, current_admin) do
      on(:invalid) do
        flash[:error] = t("census.orders_batches.action_message.not_processed")
      end
      on(:issues) do
        flash[:warning] = t("census.orders_batches.action_message.issues")
      end
      on(:ok) do
        flash[:notice] = t("census.orders_batches.action_message.processed")
      end
    end
    redirect_back(fallback_location: orders_batches_path)
  end

  controller do
    def build_resource
      build_params = permitted_params[:orders_batch] || {}
      build_params[:orders_from] = OrdersWithoutOrdersBatch.new.merge(OrdersPending.new).first.created_at.to_date unless build_params[:orders_from]
      build_params[:orders_to] = Date.today unless build_params[:orders_to]

      resource = decorator_class.new(OrdersBatchForm.from_params(build_params))
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
