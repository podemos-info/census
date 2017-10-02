# frozen_string_literal: true

ActiveAdmin.register Visit do
  decorate_with VisitDecorator
  before_action :do_not_track_page_view

  menu parent: :system

  belongs_to :admin, optional: true

  actions :index, :show

  index do
    column :started_at, class: :left do |visit|
      link_to pretty_format(visit.started_at), admin_visit_path(admin_id: visit.admin.id, id: visit.id)
    end
    column :admin
    column :ip
    column :location
    actions
  end

  show do
    panel t("census.visits.basic") do
      attributes_table_for resource do
        row :started_at
        row :admin
        row :ip
      end
    end

    panel t("census.visits.browsing") do
      attributes_table_for resource do
        row :referrer
        row :landing_page
        row :browser
        row :os
        row :device_type
      end
    end

    panel t("census.visits.location") do
      attributes_table_for resource do
        row :location
        row :postal_code
        row :coordinates
      end
    end
  end

  action_item :view_events, only: :show do
    link_to t("census.visits.view_events"), visit_events_path(visit_id: resource.id)
  end
end
