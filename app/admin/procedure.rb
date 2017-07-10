# frozen_string_literal: true

ActiveAdmin.register Procedure do
  config.sort_order = "created_at_asc"

  decorate_with ProcedureDecorator
  menu label: -> { "#{Procedure.model_name.human(count: 2)} (#{Procedure.pending.count})" }

  actions :index, :show, :edit, :update # edit is used for procedure processing
  config.clear_action_items! # hide edit button on show view

  permit_params [:result_comment, :result]

  scope :all
  scope :pending, default: true

  index do
    column :person
    column :type, &:type_name
    column :created_at
    column :result do |procedure|
      status_tag(procedure.result_name)
    end
    actions defaults: false do |procedure|
      if procedure.pending?
        link_to t("census.procedure.process"), edit_procedure_path(procedure), class: "member_link"
      else
        link_to t("active_admin.view"), procedure_path(procedure), class: "member_link"
      end
    end
  end

  show do
    columns class: "attachments" do
      column do
        attributes_table do
          row :type, &:type_name
          row :created_at
          row :result do
            status_tag(procedure.result_name)
          end
          row :processed_by
          row :processed_at
          row :result_comment if procedure.result_comment.present?
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
            f.input :result, as: :radio, collection: { t("census.procedure.approve") => true, t("census.procedure.deny") => false }
            f.input :result_comment, as: :text
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

  controller do
    def update
      procedure = assign_attributes(resource, procedure_process_params)
      ProcessProcedure.call(procedure, current_user) do
        on(:invalid) { render :edit }
        on(:ok) do
          if procedure.result
            flash[:notice] = t("census.procedure.approved", link: view_context.link_to(resource.id, resource)).html_safe
          else
            flash[:error] = t("census.procedure.denied", link: view_context.link_to(resource.id, resource)).html_safe
          end
          redirect_to next_pending_path
        end
      end
    end

    def procedure_process_params
      params.require(:procedure).permit(:result, :result_comment)
    end

    def next_pending_path
      pending = Procedure.pending.first
      pending ? edit_procedure_path(pending) : procedures_path
    end
  end
end
