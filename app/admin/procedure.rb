# frozen_string_literal: true

ActiveAdmin.register Procedure do
  decorate_with ProcedureDecorator
  belongs_to :person, optional: true

  menu parent: I18n.t("active_admin.census")

  includes :person, :issues

  config.sort_order = "created_at_asc"

  actions :index, :show, :edit, :update # edit is used for procedure processing
  config.clear_action_items! # hide edit button on show view

  permit_params :action, :comment

  filter :type, as: :select, collection: -> { ProcedureDecorator.procedures_options }

  order_by(:full_name) do |order_clause|
    "people.last_name1 #{order_clause.order}, people.last_name2 #{order_clause.order}, people.first_name #{order_clause.order}"
  end

  order_by(:type) do |order_clause|
    "#{order_clause.to_sql}, id #{order_clause.order}"
  end

  scope(:without_open_issues, group: :pending, default: true) { |scope| scope.pending.without_open_issues }
  scope(:with_open_issues, group: :pending) { |scope| scope.pending.with_open_issues }

  scope :accepted, group: :archive
  scope :rejected, group: :archive
  scope :dismissed, group: :archive

  index do
    column :created_at
    column :type, class: :left, sortable: :type do |procedure|
      issues_icons(procedure, context: self)
      procedure.link_with_name
    end
    column :person, class: :left, sortable: :full_name
    state_column :state
    actions defaults: false do |procedure|
      span procedure.link
      if procedure.full_undoable_by? controller.current_admin
        span link_to t("census.procedures.actions.undo"), undo_procedure_path(procedure), method: :patch,
                                                                                          data: { confirm: t("census.messages.sure_question") },
                                                                                          class: "member_link"
      end
    end
  end

  show do
    render "procedures/#{procedure.procedure_type}/show", context: self,
                                                          classes: procedure.last_version_classed_changeset,
                                                          person_classes: procedure.processed_person_classed_changeset
    active_admin_comments
  end

  form partial: "procedures/form", title: I18n.t("census.procedures.process"), decorate: true

  sidebar :issues, partial: "procedures/issues", only: [:show, :edit], if: -> { procedure.issues.any? }

  action_item :undo_procedure, only: :show do
    if procedure.full_undoable_by? controller.current_admin
      link_to t("census.procedures.actions.undo"), undo_procedure_path(procedure), method: :patch,
                                                                                   data: { confirm: t("census.messages.sure_question") },
                                                                                   class: "member_link"
    end
  end

  member_action :undo, method: :patch do
    procedure = resource
    Procedures::UndoProcedure.call(procedure: procedure, admin: current_admin) do
      on(:invalid) do
        flash[:error] = t("census.procedures.action_message.cant_undo", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
      on(:error) do
        flash[:error] = t("census.procedures.action_message.error_undo", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
      on(:ok) do
        flash[:notice] = t("census.procedures.action_message.undone", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
    end
    redirect_back(fallback_location: procedures_path)
  end

  member_action :view_attachment do
    attachment = Attachment.find_by(id: params[:attachment_id], procedure_id: params[:id])
    file = attachment.file.versions[params[:version]] || attachment.file
    send_data file.file.read, type: attachment.content_type, disposition: "inline"
  end

  controller do
    def scoped_collection
      end_of_association_chain.independent
    end

    def edit
      redirect_back(fallback_location: procedures_path, error: t("census.procedures.action_message.cant_process")) && return if resource.processed?
      super
    end

    def update
      Procedures::ProcessProcedure.call(form: form_resource, admin: current_admin) do
        on(:invalid) { render :edit }
        on(:error) do
          flash.now[:error] = t("census.procedures.action_message.error")
          render :edit
        end
        on(:issue_error) do
          flash.now[:error] = t("census.procedures.action_message.error_issue")
          render :edit
        end
        on(:ok) do
          flash[:notice] = t("census.procedures.action_message.#{resource.state}", link: view_context.link_to(resource.id, resource)).html_safe
          redirect_to procedures_path
        end
        on(:issue_ok) do
          flash[:notice] = t("census.procedures.action_message.issue", link: view_context.link_to(resource.id, resource)).html_safe
          redirect_to procedures_path
        end
      end
    end

    def form_resource
      @form_resource ||= Procedures::ProcessProcedureForm.from_params(permitted_params, procedure: resource, processed_by: current_admin)
    end
  end
end
