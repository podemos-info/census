# frozen_string_literal: true

ActiveAdmin.register Admin do
  decorate_with AdminDecorator

  menu parent: :system

  actions :index, :show

  index do
    column :username, class: :left do |admin|
      link_to admin.username, admin_path(id: admin.id)
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  sidebar :versions, partial: "admins/versions", only: :show
  sidebar :visits, partial: "admins/visits", only: :show
end
