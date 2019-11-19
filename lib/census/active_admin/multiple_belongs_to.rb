# frozen_string_literal: true

# Fix for bug when using multiple belongs_to.
# It will be needed until https://github.com/activeadmin/activeadmin/pull/5938 or a similar change is merged and released.
ActiveAdmin::ResourceController::PolymorphicRoutes.module_eval do
  def to_named_resource(record)
    return ActiveAdmin::Model.new(active_admin_config, record) if record.is_a?(resource_class)

    belongs_to_resource = active_admin_config.belongs_to_config.try(:resource)
    return ActiveAdmin::Model.new(belongs_to_resource, record) if belongs_to_resource && record.is_a?(belongs_to_resource.resource_class)

    record
  end
end
