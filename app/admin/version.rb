# frozen_string_literal: true

ActiveAdmin.register Version do
  decorate_with VersionDecorator
  before_action :do_not_track_page_view

  menu parent: I18n.t("active_admin.system")

  belongs_to :person, polymorphic: true, optional: true
  belongs_to :admin, polymorphic: true, optional: true
  belongs_to :order, polymorphic: true, optional: true
  belongs_to :orders_batch, polymorphic: true, optional: true
  belongs_to :payment_method, polymorphic: true, optional: true

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
                                                    classes: resource.before_classed_changeset
        end

        tab t("census.versions.after.tab") do
          render "#{resource.item_route_key}/show", title: t("census.versions.after.title"),
                                                    context: self,
                                                    resource: resource.after,
                                                    classes: resource.after_classed_changeset
        end
      end
    end
  end
end
