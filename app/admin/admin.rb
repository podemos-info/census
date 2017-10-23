# frozen_string_literal: true

ActiveAdmin.register Admin do
  decorate_with AdminDecorator

  menu parent: I18n.t("active_admin.system")

  actions :index, :show, :edit, :update

  index do
    column :username, class: :left do |admin|
      link_to admin.username, admin_path(id: admin.id)
    end
    column :name
    column :role_name
    column :created_at
    actions
  end

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  sidebar :versions, partial: "admins/versions", only: :show
  sidebar :visits, partial: "admins/visits", only: :show

  permit_params :role

  form decorate: true do |f|
    f.inputs do
      f.input :username, as: :string, input_html: { disabled: true }
      f.input :name, label: t("activerecord.attributes.admin.person"), as: :string, input_html: { disabled: true }
      f.input :role, as: :radio, collection: AdminDecorator.role_options
    end

    f.actions
  end
end
