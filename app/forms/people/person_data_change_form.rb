# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataChangeForm < PersonDataForm
    include ::HasPerson

    ID_ATTRIBUTES = [:id, :person_id, :qualified_id].freeze
    DOCUMENT_ATTRIBUTES = [:document_type, :document_id, :document_scope_id].freeze
    SCOPE_ATTRIBUTES = [:scope, :document_scope, :address_scope].freeze

    mimic :person

    attribute :ignore_email, Boolean

    def complete_required?
      false
    end

    def has_changes?
      changed_data.any?
    end

    def changed_data
      add_implicit_changes(ignore_changes(changed_attributes))
    end

    def updatable_attributes
      self.class.attribute_set.map(&:name) - ID_ATTRIBUTES
    end

    private

    def changed_attributes
      updatable_attributes
        .select { |attribute| person.respond_to?(attribute) }
        .map { |attribute| [attribute, send(attribute)] }
        .select { |attribute, value| value && value != person.send(attribute) }
        .compact.to_h
    end

    def add_implicit_changes(changes)
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

    def ignore_changes(changes)
      return changes unless ignore_email

      changes.except(:email)
    end
  end
end
