# frozen_string_literal: true

module ExternalSystems
  extend ActiveSupport::Concern

  included do
    store_accessor :external_ids, *Settings.people.external_systems.map(&:to_sym)

    def qualified_id
      "#{id}@census"
    end

    def qualified_id_at(external_system)
      external_id = external_ids[external_system.to_s]
      "#{external_id}@#{external_system}" if external_id
    end

    def qualified_id_by_document_id
      "#{document_id}@document_id"
    end
  end

  class_methods do
    def qualified_find(qualified_id)
      id, external_system = parse_qualified_id(qualified_id)
      if id.nil?
        nil
      elsif external_system == "census"
        find_by id: id
      elsif external_system == "document_id"
        find_by document_id: id
      else
        external_system_find id, external_system
      end
    end

    def external_system_find(id, external_system)
      find_by "external_ids @> ?", { external_system => id }.to_json
    end

    def parse_qualified_id(qualified_id)
      id, external_system = qualified_id.to_s.split("@")
      id = prepare_external_system_id(id, external_system)
      [id, external_system] if id.present? && external_system.present?
    end

    def prepare_external_system_id(id, external_system)
      return id if external_system == "document_id"

      id.to_i if id.to_i.positive?
    end
  end
end
