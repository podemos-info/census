# frozen_string_literal: true

ActiveAdmin.register Person do
  decorate_with PersonDecorator

  menu parent: I18n.t("active_admin.census")

  includes :scope

  actions :index, :show, :new, :create, :edit, :update

  permit_params :first_name, :last_name1, :last_name2, :document_type, :document_id,
                :born_at, :gender, :address, :postal_code, :email, :phone, :extra

  order_by(:full_name) do |order_clause|
    "last_name1 #{order_clause.order}, last_name2 #{order_clause.order}, first_name #{order_clause.order}"
  end

  order_by(:full_document) do |order_clause|
    "document_type #{order_clause.order}, document_id #{order_clause.order}"
  end

  order_by(:scope) do |order_clause|
    "scopes.name #{order_clause.order}"
  end

  order_by(:flags) do |order_clause|
    "verifications #{order_clause.order}, flags #{order_clause.order}"
  end

  index do
    id_column
    state_column :level
    column :full_name_link, sortable: :full_name, class: :left
    column :full_document, sortable: :full_document, class: :left
    column :scope, sortable: :scope, class: :left do |person|
      person.scope&.show_path(Scope.local)
    end
    column :flags, sortable: :flags do |person|
      model_flags person
    end
    actions
  end

  scope :all
  Person.levels.each do |level|
    scope level.to_sym
  end
  scope :deleted

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  form decorate: true do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name1
      f.input :last_name2
      f.input :document_type, as: :radio, collection: PersonDecorator.document_type_options
      f.input :document_id
      f.input :born_at, as: :datepicker
      f.input :gender, as: :radio, collection: PersonDecorator.gender_options
      f.input :address
      f.input :postal_code
      f.input :email
      f.input :phone
      f.input :extra, as: :text
    end

    f.actions
  end

  sidebar :procedures, partial: "people/procedures", only: :show
  sidebar :orders, partial: "people/orders", only: :show
  sidebar :downloads, partial: "people/downloads", only: :show
  sidebar :versions, partial: "people/versions", only: :show
end
