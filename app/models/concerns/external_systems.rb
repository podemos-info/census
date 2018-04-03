# frozen_string_literal: true

module ExternalSystems
  extend ActiveSupport::Concern

  included do
    def self.qualified_find(id_and_system)
      id, external_system = id_and_system.to_s.split("@")
      return unless external_system

      if external_system == "census"
        find_by id: id
      else
        find_by "external_ids @> ?", { "id_at_#{external_system}" => id.to_i }.to_json
      end
    end

    def self.external_ids_attributes
      @external_ids_attributes ||= Settings.people.external_systems.map { |external_system| :"id_at_#{external_system}" }
    end

    store_accessor :external_ids, *external_ids_attributes

    def qualified_id
      "#{id}@census"
    end

    def qualified_id_at(external_system)
      external_id = external_ids["id_at_#{external_system}"]
      "#{external_id}@#{external_system}" if external_id
    end
  end
end
