# frozen_string_literal: true

ActiveAdmin.register Event do
  decorate_with EventDecorator
  before_action :do_not_track_page_view

  menu parent: I18n.t("active_admin.system")

  belongs_to :visit, optional: true

  includes :visit, :admin

  actions :index, :show

  index do
    if association_chain.any?
      column :name, class: :left do |event|
        link_to event.name, visit_event_path(visit_id: event.visit_id, id: event.id)
      end
      column :description
    else
      column :name, class: :left do |event|
        link_to event.name, event_path(id: event.id)
      end
      column :description
      column :visit
      column :admin
    end
    column :time
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :visit
      row :admin
      row :time
    end

    panel "properties" do
      attributes_table_for resource.properties do
        resource.properties.each do |key, value|
          row(key) { value }
        end
      end
    end
  end
end
