# frozen_string_literal: true

ActiveAdmin.register Procedure do
  decorate_with ProcedureDecorator
  belongs_to :person, optional: true

  menu parent: I18n.t("active_admin.census")

  includes :person, :issues

  config.sort_order = "created_at_desc"

  actions :index, :show, :update # update is used for procedure processing

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
    column :processor, class: :left do |procedure|
      if procedure.processed_by
        procedure.processed_by.with_icon
      elsif procedure.processing_by
        procedure.processing_by.with_icon(modifier: "locked")
      elsif procedure.processed?
        span "auto", class: "admin_icon auto"
      end
    end
    column :created_at
  end

  show do
    if procedure.processable?
      controller.lock(resource.object)
      script { raw "window.procedure_channel = new ProceduresChannel(#{procedure.id}, #{procedure.lock_version})" }
    end

    panel procedure.name do
      render "procedures/#{procedure.procedure_type}/show", context: self
    end
    active_admin_comments
  end

  sidebar :issues, partial: "procedures/issues", only: [:show], if: -> { procedure.issues.any? }
  sidebar :person, partial: "procedures/person", only: [:show]

  action_item :process_flow, only: :index do
    link_to t("census.procedures.process"), next_document_verification_procedures_path
  end

  action_item :undo_procedure, only: :show do
    if procedure.undoable_by? controller.current_admin
      link_to t("census.procedures.actions.undo"), undo_procedure_path(procedure, lock_version: procedure.lock_version),
              method: :patch,
              data: { confirm: t("census.messages.sure_question") },
              class: "member_link"
    end
  end

  collection_action :next_document_verification do
    browse_ordered_procedures do |next_procedure|
      return redirect_to(procedure_path(next_procedure)) if lock(next_procedure)
    end

    flash.now[:notice] = t("census.procedures.action_message.no_next_procedure")
    redirect_to procedures_path
  end

  member_action :undo, method: :patch do
    procedure = resource
    Procedures::UndoProcedure.call(form: undo_form, admin: current_admin) do
      on(:conflict) do
        flash[:error] = t("census.procedures.action_message.conflict", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
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
    def browse_ordered_procedures(&block)
      browse_procedures(ProceduresPrioritizedDocumentVerifications.since(2.weeks.ago), &block)
      browse_procedures(ProceduresDocumentVerifications.new.query, &block)
    end

    def browse_procedures(procedures)
      procedures.limit(50).each do |procedure|
        yield(procedure) if procedure.acceptable?
      end
    end

    def update
      set_resource_ivar resource.decorate

      Procedures::ProcessProcedure.call(form: process_form, admin: current_admin) do
        on(:invalid) { render :show }
        on(:busy) { render_error(:busy) }
        on(:conflict) { render_error(:conflict) }
        on(:error) { render_error(:error) }
        on(:issue_error) { render_error(:issue_error) }
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

    def process_form
      @process_form ||= Procedures::ProcessProcedureForm.from_params(process_params, procedure: resource.object, processed_by: current_admin)
    end

    def process_params
      params.permit :id, procedure: [:action, :comment, :lock_version]
    end

    def undo_form
      @undo_form ||= Procedures::UndoProcedureForm.from_params(undo_params, procedure: resource.object)
    end

    def undo_params
      params.permit :lock_version
    end

    def lock(procedure_to_lock)
      ret = false
      Procedures::LockProcedure.call(form: lock_form(procedure_to_lock), admin: current_admin) do
        on(:ok) { ret = true }
        on(:noop) { ret = true }
      end
      ret
    end

    def lock_form(procedure_to_lock)
      @lock_form ||= Procedures::LockProcedureForm.from_params(procedure: procedure_to_lock, lock_version: procedure_to_lock.lock_version)
    end

    def render_error(message)
      flash.now[:error] = t("census.procedures.action_message.#{message}")
      render :show
    end
  end
end
