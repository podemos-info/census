# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataChangeForm < PersonDataForm
    include ::HasPerson

    ID_ATTRIBUTES = [:id, :person_id, :qualified_id].freeze
    DOCUMENT_ATTRIBUTES = [:document_type, :document_id, :document_scope_id].freeze
    SCOPE_ATTRIBUTES = [:scope, :document_scope, :address_scope].freeze

    mimic :person

    def complete_required?
      false
    end

    def has_changes?
      changed_data.any?
    end

    def changed_data
      add_extra_changes(updatable_attributes.map do |attribute|
        next unless person.respond_to?(attribute)
        value = send(attribute)
        [attribute, value] if value && value != person.send(attribute)
      end.compact.to_h)
    end

    def updatable_attributes
      self.class.attribute_set.map(&:name) - ID_ATTRIBUTES
    end

    private

    def add_extra_changes(changes)
      SCOPE_ATTRIBUTES.each do |attribute|
        value = send(attribute)
        changes[:"#{attribute}_id"] = value.id if value && value != person.send(attribute)
      end

      if (DOCUMENT_ATTRIBUTES & changes.keys).any?
        DOCUMENT_ATTRIBUTES.each do |attribute|
          changes[attribute] ||= person.send(attribute)
        end
      end
      changes
    end
  end
end
