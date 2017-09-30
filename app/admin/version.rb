# frozen_string_literal: true

ActiveAdmin.register Version do
  decorate_with VersionDecorator
  before_action :do_not_track_page_view

  menu parent: :system

  controller do
    belongs_to :admin, :order, :orders_batch, :person, :procedure, :payment_method, polymorphic: true, optional: true
  end

  actions :index, :show

  index do
    column :created_at, class: :left do |version|
      link_to pretty_format(version.created_at), version.build_path(association_chain)
    end
    column :description, class: :left
    column :item, class: :left unless association_chain.any?
    column :author
  end

  show do
    tabs do
      tab t("census.versions.description.tab") do
        panel t("census.versions.description.title") do
          attributes_table_for resource do
            row :item
            row :description
            row :author
            row :created_at
          end
        end
      end

      if resource.update?
        tab t("census.versions.before.tab") do
          render "#{resource.item_route_key}/show", title: t("census.versions.before.title"),
                                                    context: self,
                                                    resource: resource.before,
                                                    classes: classed_changeset(resource, "version_change old_value")
        end

        tab t("census.versions.after.tab") do
          render "#{resource.item_route_key}/show", title: t("census.versions.after.title"),
                                                    resource: resource.after,
                                                    context: self,
                                                    classes: classed_changeset(resource, "version_change new_value")
        end
      end
    end
  end
end
