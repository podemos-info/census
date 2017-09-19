# frozen_string_literal: true

ActiveAdmin.register PaymentMethod do
  decorate_with PaymentMethodDecorator

  includes :person

  actions :index, :show

  menu parent: :orders

  index do
    id_column
    column :person, class: :left, sortable: "people.last_name1"
    column :name, class: :left
    column :type, &:type_name
    actions
  end

  show do
    attributes_table do
      row :id
      row :person
      row :name
      row :type, &:type_name
      row :created_at
      row :updated_at
    end
    show_table(self, t("census.payment_methods.information"), payment_method.information) if payment_method.information.any?
    active_admin_comments
  end

  action_item(:create_order, only: :show) do
    link_to t("census.payment_methods.create_order"), new_order_path(order: { payment_method_id: payment_method.id })
  end
end
