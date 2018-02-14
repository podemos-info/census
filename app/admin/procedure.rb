# frozen_string_literal: true

ActiveAdmin.register Procedure do
  decorate_with ProcedureDecorator
  belongs_to :person, optional: true

  menu parent: I18n.t("active_admin.census")

  includes :person

  config.sort_order = "created_at_asc"

  actions :index, :show, :edit, :update # edit is used for procedure processing
  config.clear_action_items! # hide edit button on show view

  permit_params [:result_comment, :result]

  filter :type, as: :select, collection: -> { ProcedureDecorator.procedures_options }

  order_by(:full_name) do |order_clause|
    "people.last_name1 #{order_clause.order}, people.last_name2 #{order_clause.order}, people.first_name #{order_clause.order}"
  end

  order_by(:type) do |order_clause|
    "#{order_clause.to_sql}, id #{order_clause.order}"
  end

  scope :all
  Procedure.aasm.states.each do |state|
    scope state.name, default: state == :pending
  end

  index do
    column :type, sortable: :type do |procedure|
      procedure.view_link procedure.name
    end
    column :person, class: :left, sortable: :full_name
    column :created_at, class: :left
    state_column :state
    actions defaults: false do |procedure|
      span procedure.view_link
      if procedure.full_undoable_by? controller.current_admin
        span link_to t("census.procedures.events.undo"), undo_procedure_path(procedure), method: :patch,
                                                                                         data: { confirm: t("census.messages.sure_question") },
                                                                                         class: "member_link"
      end
    end
  end

  show do
    columns class: "attachments" do
      column do
        render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
        render "personal_data"
      end
      if procedure.attachments.any?
        column do
          procedure.attachments.each do |attachment|
            a href: attachment.view_path do
              if attachment.image?
                img src: attachment.view_path(version: :thumbnail)
              else
                attachment.file.file.original_filename
              end
            end
          end
        end
      end
    end
    if procedure.dependent_procedures.any?
      panel I18n.t("census.procedures.dependent_procedures") do
        table_for procedure.dependent_procedures, i18n: Procedure do
          column :type, &:type_name
          column :information
        end
      end
    end
    active_admin_comments
  end

  form title: I18n.t("census.procedures.process"), decorate: true do |f|
    columns class: "attachments" do
      column do
        render partial: "personal_data"

        if procedure.dependent_procedures.any?
          panel I18n.t("census.procedures.dependent_procedures") do
            table_for procedure.dependent_procedures, i18n: Procedure do
              column :type, &:type_name
              column :information
            end
          end
        end

        panel t("census.procedures.process") do
          f.inputs do
            f.input :event, as: :radio, label: false, collection: procedure.permitted_events_options(controller.current_admin)
            f.input :comment, as: :text
          end
          f.actions
        end
      end
      column do
        procedure.attachments.each do |attachment|
          a href: attachment.view_path do
            if attachment.image?
              img src: attachment.view_path(version: :thumbnail)
            else
              attachment.file.file.original_filename
            end
          end
        end
      end
    end
  end

  member_action :undo, method: :patch do
    procedure = resource
    Procedures::UndoProcedure.call(procedure, current_admin) do
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
      procedure = resource

      Procedures::ProcessProcedure.call(procedure, current_admin, params[:procedure]) do
        on(:invalid) { render :edit }
        on(:error) do
          flash[:error] = t("census.procedures.action_message.error")
          render :edit
        end
        on(:ok) do
          flash[:notice] = t("census.procedures.action_message.#{procedure.state}", link: view_context.link_to(procedure.id, procedure)).html_safe
          redirect_to next_pending_path
        end
      end
    end

    def next_pending_path
      pending = Procedure.pending.first
      pending ? edit_procedure_path(pending) : procedures_path
    end
  end
end
