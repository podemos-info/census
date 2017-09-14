# frozen_string_literal: true

ActiveAdmin.register Order do
  decorate_with OrderDecorator

  includes :person, :payment_method

  actions :index, :show

  index do
    id_column
    column :payment_method
    column :person, class: :left
    column :orders_batch
    state_column :state
    column :full_amount, class: :right
    actions
  end

  show do
    attributes_table do
      state_row :state
      row :id
      row :payment_method
      row :description
      row :full_amount
      row :created_at
      row :updated_at
    end
    show_table(self, t("census.orders.information"), order.information) if order.information.any?
    active_admin_comments
  end
end
