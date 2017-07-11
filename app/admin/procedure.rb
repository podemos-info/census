# frozen_string_literal: true

ActiveAdmin.register Procedure do
  config.sort_order = "created_at_asc"

  decorate_with ProcedureDecorator
  menu label: -> { "#{Procedure.model_name.human(count: 2)} [#{Procedure.pending.count}/#{Procedure.issues.count}]" }

  actions :index, :show, :edit, :update # edit is used for procedure processing
  config.clear_action_items! # hide edit button on show view

  permit_params [:result_comment, :result]

  scope :all
  Procedure.aasm.states.each do |state|
    scope state.name, default: state==:pending
  end
  
  index do
    column :person
    column :type, &:type_name
    column :created_at
    state_column :state
    actions defaults: false do |procedure|
      if procedure.processable?
        span link_to t("census.procedure.process"), edit_procedure_path(procedure), class: "member_link"
      else
        span link_to t("active_admin.view"), procedure_path(procedure), class: "member_link"
      end
      if procedure.undoable?
        span link_to t("census.procedure.events.undo"), undo_procedure_path(procedure), class: "member_link"
      end
    end
  end

  show do
    columns class: "attachments" do
      column do
        attributes_table do
          row :type, &:type_name
          row :created_at
          state_row :state
          row :processed_by
          row :processed_at
          row :comment if procedure.comment.present?
        end

        render partial: "personal_data"
      end
      if procedure.attachments.any?
        column do
          procedure.attachments.each do |attachment|
            a href: attachment.file_url do
              if attachment.image?
                img src: attachment.file_url
              else
                t("download")
              end
            end
          end
        end
      end
    end
  end

  form title: I18n.t("census.procedure.process"), decorate: true do |f|
    columns class: "attachments" do
      column do
        render partial: "personal_data"

        panel t("census.procedure.process") do
          f.inputs do
            f.input :event, as: :radio, collection: f.object.available_events_options
            f.input :comment, as: :text
          end
          f.actions
        end
      end
      column do
        procedure.attachments.each do |attachment|
          a href: attachment.file_url do
            if attachment.image?
              img src: attachment.file_url
            else
              t("download")
            end
          end
        end
      end
    end
  end

  member_action :undo do
    procedure = resource
    ProcessProcedure.call(procedure, "undo", current_user) do
      on(:invalid) do
        flash[:error] = t("census.procedure.action_message.cant_undo", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
      on(:ok) do
        flash[:notice] = t("census.procedure.action_message.undo", link: view_context.link_to(procedure.id, procedure)).html_safe
      end
    end
    redirect_to(:back)
  end

  controller do
    def update
      procedure = resource
      procedure.comment = params[:procedure][:comment]
      safe_event = (procedure.aasm.events(permitted: true).map(&:name) & [params[:procedure][:event].to_sym]).first
      
      ProcessProcedure.call(procedure, safe_event, current_user) do
        on(:invalid) { render :edit }
        on(:ok) do
          flash[:notice] = t("census.procedure.action_message.#{procedure.state}", link: view_context.link_to(procedure.id, procedure)).html_safe
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
