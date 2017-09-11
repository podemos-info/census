# frozen_string_literal: true

ActiveAdmin.register PaymentMethod do
  decorate_with PaymentMethodDecorator

  includes :person

  menu parent: :orders

  index do
    id_column
    column :person, class: :left, sortable: "people.last_name1"
    column :name, class: :left
    column :type, &:type_name
    actions
  end
end
