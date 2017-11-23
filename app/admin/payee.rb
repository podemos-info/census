# frozen_string_literal: true

ActiveAdmin.register Payee do
  decorate_with PayeeDecorator

  menu parent: I18n.t("active_admin.payments")

  index do
    column :name
    column :scope
    actions
  end

  permit_params :name, :iban, :scope_id

  form decorate: true do |f|
    f.inputs do
      f.input :name
      f.input :iban
      f.input :scope_id, as: :data_picker, text: :full_scope,
                         url: browse_scopes_path(root: Scope.local, current: payee.scope_id, title: Person.human_attribute_name(:scope).downcase)
    end

    f.actions
  end
end
