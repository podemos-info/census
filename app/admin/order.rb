# frozen_string_literal: true

ActiveAdmin.register Order do
  decorate_with OrderDecorator

  belongs_to :orders_batch, optional: true
  belongs_to :person, optional: true

  menu parent: I18n.t("active_admin.payments")

  includes :person, :payment_method, :orders_batch

  permit_params :person_id, :payment_method_id, :description, :full_amount, :campaign_code

  actions :index, :show, :new, :create
  config.clear_action_items!

  scope :all, default: true
  Order.state_names.each do |state|
    scope state.to_sym
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
    render "show", context: self, classes: resource.last_version_classed_changeset
    active_admin_comments
  end

  sidebar :versions, partial: "orders/versions", only: :show

  action_item :process, only: :show do
    if policy(resource).charge? && order.processable?(inside_batch?: false)
      link_to(
        t("census.orders.process"), charge_order_path(order), method: :patch,
                                                              data: { confirm: t("census.messages.sure_question") },
                                                              class: :member_link
      )
    end
  end

  form decorate: true do |f|
    controller.redirect_to(orders_path) && next unless f.object.person

    inputs do
      input :person_id, as: :hidden
      input :payment_method_id, as: :hidden
      input :person_full_name, label: t("activerecord.attributes.order.person"), as: :string, input_html: { disabled: true }
      input :payment_method_name, label: t("activerecord.attributes.order.payment_method"), as: :string, input_html: { disabled: true }
      input :description
      input :full_amount, as: :number
      input :campaign_code
    end

    actions
  end

  member_action :charge, method: :patch do # Fails when calling it :process
    order = resource
    Payments::ProcessOrder.call(order: order, admin: current_admin) do
      on(:invalid) do
        flash[:error] = t("census.orders.action_message.not_processed")
      end
      on(:error) do
        flash[:error] = t("census.orders.action_message.processing_error")
      end
      on(:order_issues) do
        flash[:notice] = t("census.orders.action_message.order_issues")
      end
      on(:order_issues_error) do
        flash[:notice] = t("census.orders.action_message.order_issues_error")
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
      build_params[:amount] = (build_params[:full_amount].to_f * 100).to_i
      if build_params[:payment_method_id].present?
        form_class = Orders::ExistingPaymentMethodOrderForm
      elsif build_params[:person_id]
        form_class = Orders::CreditCardExternalOrderForm
        build_params[:return_url] = external_payment_result_orders_url(result: "__RESULT__")
      else
        flash.now[:alert] = t("census.orders.add_orders_from_payment_methods")
      end

      resource = form_class ? decorator_class.new(form_class.from_params(build_params)) : Order.new
      set_resource_ivar resource

      resource
    end

    def create
      form = build_resource
      Payments::CreateOrder.call(form: form, admin: current_admin) do
        on(:invalid) { render :new }
        on(:error) do
          flash.now[:error] = t("census.messages.error_occurred")
          render :new
        end
        on(:external) do |info|
          append_content_security_policy_directives script_src: ["'unsafe-inline'"]
          append_content_security_policy_directives form_action: [info[:form][:action]]
          render "payment_form", locals: { form_info: info[:form] }
        end
        on(:ok) { |info| redirect_to order_path(id: info[:order].id) }
      end
    end

    def issues_for_resource
      @issues_for_resource ||= super + IssuesOpen.for.merge(AdminIssues.for(current_admin)).merge(resource.payment_method.issues).decorate
    end
  end
end
