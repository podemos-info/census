# frozen_string_literal: true

ActiveAdmin.register Procedure do
  decorate_with ProcedureDecorator
  belongs_to :person, optional: true

  menu parent: I18n.t("active_admin.census")

  includes :person, :issues

  config.sort_order = "created_at_desc"

  actions :index, :show, :update # update is used for procedure processing

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
    column :id do |procedure|
      procedure.link(procedure.id)
    end
    column :type, class: :left, sortable: :type do |procedure|
      issues_icons(procedure, context: self)
      procedure.link(procedure.type_name)
    end
    column :person, class: :left, sortable: :full_name
    column :scope, sortable: :scope, class: :left do |procedure|
      procedure.person.scope&.local_path
    end
    state_column :state
    bool_column :auto_processed?
    column :created_at
  end

  show do
    panel procedure.name do
      render "procedures/#{procedure.procedure_type}/show", context: self
    end
    active_admin_comments
  end

  sidebar :issues, partial: "procedures/issues", only: [:show], if: -> { procedure.issues.any? }
  sidebar :person, partial: "procedures/person", only: [:show]

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

    def update
      set_resource_ivar resource.decorate
      Procedures::ProcessProcedure.call(form: form_resource, admin: current_admin) do
        on(:invalid) { render :show }
        on(:error) do
          flash.now[:error] = t("census.procedures.action_message.error")
          render :show
        end
        on(:issue_error) do
          flash.now[:error] = t("census.procedures.action_message.error_issue")
          render :show
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
