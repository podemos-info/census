# frozen_string_literal: true

ActiveAdmin.register PaymentMethod do
  decorate_with PaymentMethodDecorator
  belongs_to :person, optional: true

  includes :person

  permit_params :person_id, :name, :iban

  actions :index, :show, :new, :create, :edit, :update, :destroy
  config.clear_action_items!

  menu parent: I18n.t("active_admin.payments")

  [:direct_debit, :credit_card].each do |payment_method|
    scope(payment_method) { |scope| scope.where type: "PaymentMethods::#{payment_method.to_s.classify}" }
  end

  order_by(:full_name) do |order_clause|
    "people.last_name1 #{order_clause.order}, people.last_name2 #{order_clause.order}, people.first_name #{order_clause.order}"
  end

  index do
    column :name, class: :left do |payment_method|
      link_to payment_method.name, payment_method_path(id: payment_method.id)
    end
    column :person, class: :left, sortable: :full_name
    column :type_name
    actions
  end

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  form decorate: true do |f|
    controller.redirect_to(payment_methods_path) && next unless f.object.person

    inputs do
      input :person_id, as: :hidden
      input :person_full_name, label: t("activerecord.attributes.payment_method.person"), as: :string, input_html: { disabled: true }
      input :type_name, as: :string, input_html: { disabled: true }
      input :name, as: :string

      if f.object.is_a?(PaymentMethods::DirectDebit)
        input :iban, as: :string
      elsif f.object.is_a?(PaymentMethods::CreditCard)
        input :expiration_year, as: :string, input_html: { disabled: true }
        input :expiration_month, as: :string, input_html: { disabled: true }
      end
    end

    actions
  end

  sidebar :versions, partial: "payment_methods/versions", only: :show

  action_item(:create_order, only: :show) do
    link_to t("census.payment_methods.create_order"), new_order_path(order: { payment_method_id: payment_method.id })
  end

  controller do
    def build_resource
      flash[:alert] = t("census.payment_methods.add_orders_from_people") unless permitted_params[:payment_method][:person_id]
      resource = decorator_class.new(PaymentMethods::DirectDebit.new(permitted_params[:payment_method]))
      set_resource_ivar resource

      resource
    end
  end
end
