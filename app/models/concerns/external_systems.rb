# frozen_string_literal: true

module ExternalSystems
  extend ActiveSupport::Concern

  included do
    store_accessor :external_ids, *external_ids_attributes

    def qualified_id
      "#{id}@census"
    end

    def qualified_id_at(external_system)
      external_id = external_ids["id_at_#{external_system}"]
      "#{external_id}@#{external_system}" if external_id
    end
  end

  class_methods do
    def qualified_find(qualified_id)
      id, external_system = parse_qualified_id(qualified_id)

      if id.nil?
        nil
      elsif external_system == "census"
        find_by id: id
      else
        external_system_find id: id, external_system: external_system
      end
    end

    def external_system_find(id:, external_system:)
      find_by "external_ids @> ?", { "id_at_#{external_system}" => id }.to_json
    end

    def external_ids_attributes
      @external_ids_attributes ||= Settings.people.external_systems.map { |external_system| :"id_at_#{external_system}" }
    end

    def parse_qualified_id(qualified_id)
      id, external_system = qualified_id.to_s.split("@")
      id = id.to_i
      [id, external_system] if id.positive? && external_system.present?
    end
  end
end
