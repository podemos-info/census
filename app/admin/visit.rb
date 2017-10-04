# frozen_string_literal: true

ActiveAdmin.register Visit do
  decorate_with VisitDecorator
  before_action :do_not_track_page_view

  menu parent: I18n.t("active_admin.system")

  belongs_to :admin, optional: true

  actions :index, :show

  index do
    column :started_at, class: :left do |visit|
      if association_chain.any?
        link_to pretty_format(visit.started_at), admin_visit_path(admin_id: visit.admin_id, id: visit.id)
      else
        link_to pretty_format(visit.started_at), visit_path(id: visit.id)
      end
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

  sidebar :visits, partial: "visits/events", only: :show
end
