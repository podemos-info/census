# frozen_string_literal: true

ActiveAdmin.register PersonLocation do
  decorate_with PersonLocationDecorator

  belongs_to :person

  includes :person

  actions :index, :show

  index do
    column :ip
    column :user_agent
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :ip
      row :user_agent
      row :person
      row :created_at
      row :updated_at
      row :deleted_at
    end
    active_admin_comments
  end
end
