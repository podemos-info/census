# frozen_string_literal: true

ActiveAdmin.register PaymentMethod do
  decorate_with PaymentMethodDecorator
  belongs_to :person, optional: true

  includes :person

  actions :index, :show

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
    column :type, &:type_name
    actions
  end

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  sidebar :versions, partial: "payment_methods/versions", only: :show

  action_item(:create_order, only: :show) do
    link_to t("census.payment_methods.create_order"), new_order_path(order: { payment_method_id: payment_method.id })
  end
end
