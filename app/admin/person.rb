# frozen_string_literal: true

ActiveAdmin.register Person do
  decorate_with PersonDecorator

  menu parent: I18n.t("active_admin.census")

  includes :scope

  permit_params :first_name, :last_name1, :last_name2, :document_type, :document_id,
                :born_at, :gender, :address, :postal_code, :email, :phone, :scope_id, :address_scope_id

  actions :index, :show, :edit, :update

  order_by(:full_name) do |order_clause|
    "last_name1 #{order_clause.order}, last_name2 #{order_clause.order}, first_name #{order_clause.order}"
  end

  order_by(:full_document) do |order_clause|
    "document_type #{order_clause.order}, document_id #{order_clause.order}"
  end

  order_by(:scope) do |order_clause|
    "scopes.name #{order_clause.order}"
  end

  index do
    id_column
    state_column :state, machine: :state
    state_column :membership_level, machine: :membership_level
    state_column :verification, machine: :verification
    column :name_link, sortable: :full_name, class: :left
    column :full_document, sortable: :full_document, class: :left
    column :scope, sortable: :scope, class: :left do |person|
      person.scope&.show_path(Scope.local)
    end
    actions
  end

  scope :all

  Person.membership_level_names.each do |membership_level|
    scope membership_level.to_sym, group: :membership_level
  end

  Person.state_names.each do |state|
    if state == "cancelled"
      scope state.to_sym, group: :state, if: proc { current_admin.lopd_role? }
    else
      scope state.to_sym, group: :state, default: state == "enabled"
    end
  end

  show do
    render "show", context: self, classes: resource.last_version_classed_changeset
    active_admin_comments
  end

  action_item :request_verification, only: :show do
    if person.may_request_verification?
      link_to t("census.people.request_verification"), request_verification_person_path(person), method: :patch,
                                                                                                 data: { confirm: t("census.messages.sure_question") },
                                                                                                 class: "member_link"
    end
  end

  member_action :request_verification, method: :patch do
    person = resource
    People::RequestVerification.call(person: person, admin: current_admin) do
      on(:invalid) do
        flash[:error] = t("census.people.action_message.cant_request_verification", link: view_context.link_to(person.id, person)).html_safe
      end
      on(:error) do
        flash[:error] = t("census.people.action_message.error_requesting_verification", link: view_context.link_to(person.id, person)).html_safe
      end
      on(:ok) do
        flash[:notice] = t("census.people.action_message.verification_requested", link: view_context.link_to(person.id, person)).html_safe
      end
    end
    redirect_back(fallback_location: person_path)
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
      f.input :scope_id, as: :data_picker, text: :full_scope,
                         url: browse_scopes_path(root: Scope.local, current: person.scope_id, title: Person.human_attribute_name(:scope).downcase)
      f.input :address_scope_id, as: :data_picker, text: :full_address_scope,
                                 url: browse_scopes_path(current: person.address_scope_id, title: Person.human_attribute_name(:address_scope).downcase)
    end

    f.actions
  end

  sidebar :procedures, partial: "people/procedures", only: :show, if: -> { policy(Procedure).index? }
  sidebar :orders, partial: "people/orders", only: :show, if: -> { policy(Order).index? }
  sidebar :downloads, partial: "people/downloads", only: :show, if: -> { policy(Download).index? }
  sidebar :versions, partial: "people/versions", only: :show, if: -> { policy(Version).index? }
end
