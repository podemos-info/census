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
end
