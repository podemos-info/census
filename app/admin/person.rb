# frozen_string_literal: true

ActiveAdmin.register Person do
  decorate_with PersonDecorator

  menu parent: I18n.t("active_admin.census")

  includes :scope, :issues

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
    column :name, sortable: :full_name, class: :left do |person|
      issues_icons(person, context: self)
      person.name_link
    end
    column :full_document, sortable: :full_document, class: :left
    column :scope, sortable: :scope, class: :left do |person|
      person.scope&.local_path
    end
    state_column :state, machine: :state
    state_column :membership_level, machine: :membership_level
    state_column :verification, class: :left, machine: :verification
    state_column :phone_verification, class: :left, machine: :phone_verification
  end

  scope :enabled, group: :enabled, default: true
  Person.membership_level_names.each do |membership_level|
    scope membership_level.to_sym, group: :enabled
  end

  scope :pending, group: :pending

  scope :cancelled, group: :discarded
  scope :trashed, group: :discarded

  scope(:with_open_issues, group: :issues) { |scope| scope.kept.with_open_issues }

  show do
    render "show", context: self, changes: resource.last_version_classed_changeset
    active_admin_comments
  end

  action_item :request_verification, only: :show do
    next unless policy(person).request_verification? && person.may_request_verification?

    link_to t("census.people.request_verification"), request_verification_person_path(person), method: :patch,
                                                                                               data: { confirm: t("census.messages.sure_question") },
                                                                                               class: "member_link"
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

  action_item :cancellation, only: :show do
    next unless policy(person).cancellation? && person.may_cancel?

    link_to t("census.people.cancellation.action"), cancellation_person_path(person), class: "member_link"
  end

  member_action :cancellation, method: [:get, :patch] do
    form = People::CancellationForm.from_params(params, person_id: resource.id)
    if request.patch?
      People::CreateCancellation.call(form: form, admin: current_admin) do
        on(:invalid) {}
        on(:error) do
          flash.now[:error] = t("census.messages.error_occurred")
        end
        on(:ok) do
          flash[:notice] = t("census.people.action_message.cancellation_created")
          redirect_to(person_path)
        end
      end
    end
    render "cancellation", locals: { context: self, cancellation_form: form } unless response_body
  end

  form partial: "people/form", decorate: true

  sidebar :issues, partial: "people/issues", only: :show, if: -> { person.issues.any? }
  sidebar :procedures, partial: "people/procedures", only: :show, if: -> { policy(Procedure).index? && person.procedures.any? }
  sidebar :orders, partial: "people/orders", only: :show, if: -> { policy(Order).index? }
  sidebar :downloads, partial: "people/downloads", only: :show, if: -> { policy(Download).index? && person.downloads.any? }
  sidebar :versions, partial: "people/versions", only: :show, if: -> { policy(Version).index? && person.versions.any? }
  sidebar :person_locations, partial: "people/locations", only: :show, if: -> { policy(PersonLocation).index? && person.person_locations.any? }

  controller do
    def form_resource
      @form_resource ||= People::PersonDataChangeForm.from_model(resource)
    end

    def update
      @form_resource = People::PersonDataChangeForm.from_params(params, person_id: resource.id, ignore_email: true)
      People::CreatePersonDataChange.call(form: form_resource, admin: current_admin) do
        on(:invalid) do
          resource.errors.merge!(form_resource.errors)
          render :edit
        end
        on(:error) do
          flash.now[:error] = t("census.messages.error_occurred")
          render :edit
        end
        on(:noop) do
          flash[:notice] = t("census.people.action_message.no_changes_done")
          send_confirm_email_notification(:notice)
          redirect_to(person_path)
        end
        on(:ok) do
          flash[:notice] = t("census.people.action_message.person_data_change_created")
          send_confirm_email_notification(:info)
          redirect_to(person_path)
        end
      end
    end

    def send_confirm_email_notification(message_mode)
      return unless form_resource.email != resource.email

      ::People::ChangesPublisher.confirm_email_change!(resource, form_resource.email)
      flash[message_mode] = t("census.people.action_message.email_change_notification_sent")
    end
  end
end
