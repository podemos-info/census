# frozen_string_literal: true

ActiveAdmin.register Job do
  decorate_with JobDecorator

  includes :job_objects

  menu parent: :dashboard
  before_action :do_not_track_page_view

  actions :index, :show

  index do
    column :job_type_link, class: :left
    column :status_name
    column :result_name
    column :objects_links
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :job_type_name
      row :status_name
      row :result_name
      row :user
      row :objects_links
      row :created_at
      row :updated_at
    end

    panel I18n.t("census.jobs.messages") do
      table_for job.messages, i18n: ActiveJobReporter::JobMessage do
        column :created_at
        column :message
        column :related
      end
    end

    active_admin_comments
  end

  collection_action :running, method: :post do
    render json: decorated_current_admin.count_running_jobs
  end
end
