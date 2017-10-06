# frozen_string_literal: true

ActiveAdmin.register Order do
  decorate_with OrderDecorator

  controller do
    belongs_to :orders_batch, :person, optional: true
  end

  menu parent: I18n.t("active_admin.payments")

  includes :person, :payment_method, :orders_batch

  permit_params :person_id, :payment_method_id, :description, :amount

  actions :index, :show, :new, :create
  config.clear_action_items!

  [:direct_debit, :credit_card].each do |payment_method|
    scope(payment_method) do |scope|
      scope.joins(:payment_method).where(payment_methods: { type: "PaymentMethods::#{payment_method.to_s.classify}" })
    end
  end

  order_by(:full_name) do |order_clause|
    "people.last_name1 #{order_clause.order}, people.last_name2 #{order_clause.order}, people.first_name #{order_clause.order}"
  end

  index do
    column :name, class: :left, sortable: :id do |order|
      link_to order.name, order_path(id: order.id)
    end
    column :payment_method
    column :person, class: :left, sortable: :full_name
    column :created_at, class: :left
    column :orders_batch
    state_column :state
    column :full_amount, class: :right
    actions
  end

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  sidebar :versions, partial: "orders/versions", only: :show

  action_item :process, only: :show do
    link_to(t("census.orders.process"), charge_order_path(order), method: :patch, data: { confirm: t("census.sure_question") }, class: :member_link) if order.processable?(false)
  end

  form decorate: true do |f|
    controller.redirect_to(orders_path) && next unless f.object.person

    inputs do
      input :person_id, as: :hidden
      input :payment_method_id, as: :hidden
      input :person_full_name, label: t("activerecord.attributes.order.person"), as: :string, input_html: { disabled: true }
      input :payment_method_name, label: t("activerecord.attributes.order.payment_method"), as: :string, input_html: { disabled: true }
      input :description
      input :amount, as: :number
    end

    actions
  end

  member_action :charge, method: :patch do # Fails when calling it :process
    order = resource
    Payments::ProcessOrder.call(order, current_admin) do
      on(:invalid) do
        flash[:error] = t("census.orders.action_message.not_processed")
      end
      on(:ok) do
        flash[:notice] = t("census.orders.action_message.processed")
      end
    end
    redirect_back(fallback_location: orders_path)
  end

  collection_action :external_payment_result do
    if params[:result] == "ok"
      flash[:notice] = t("census.orders.created")
    else
      flash[:error] = t("census.orders.not_created")
    end
    redirect_to orders_path
  end

  controller do
    def build_resource
      build_params = permitted_params[:order] || {}
      build_params[:amount] = (build_params[:amount].to_f * 100).to_i
      if build_params[:payment_method_id].present?
        form_class = Orders::ExistingPaymentMethodOrderForm
      elsif build_params[:person_id]
        form_class = Orders::CreditCardExternalOrderForm
        build_params[:return_url] = external_payment_result_orders_url(result: "__RESULT__")
      else
        flash[:alert] = t("census.orders.add_orders_from_payment_methods")
      end

      resource = form_class ? decorator_class.new(form_class.from_params(build_params)) : Order.new
      set_resource_ivar resource

      resource
    end

    def create
      form = build_resource
      Payments::CreateOrder.call(form) do
        on(:invalid) { render :new }
        on(:external) do |order_info|
          append_content_security_policy_directives script_src: ["'unsafe-inline'"]
          append_content_security_policy_directives form_action: [order_info[:action]]
          render "payment_form", locals: { order_info: order_info }
        end
        on(:ok) { |order| redirect_to order_path(id: order.id) }
      end
    end
  end
end
