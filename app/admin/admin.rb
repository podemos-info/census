# frozen_string_literal: true

ActiveAdmin.register Admin do
  decorate_with AdminDecorator

  menu parent: :people

  actions :index, :show

  index do
    selectable_column
    id_column
    column :username
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :person
      row :username
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
    end
  end
end
