# frozen_string_literal: true

module Procedures
  class PersonDataChange < PersonDataProcedure
    def acceptable?
      person.enabled?
    end

    def process_accept
      person.assign_attributes(person_data)
      self.from_person_data = person.changed_attributes
    end

    def undo_accept
      person.assign_attributes(from_person_data)
    end

    def persist_changes!
      return unless person.has_changes_to_save?
      person.save!
      ::People::ChangesPublisher.full_status_changed!(person) if modifies?(:scope_id)
    end

    def possible_issues
      ret = []
      ret << Issues::People::DuplicatedDocument if modifies?(:document_type, :document_id, :document_scope_id)
      ret << Issues::People::DuplicatedPerson if modifies?(:born_at, :first_name, :last_name1, :last_name2)
      ret << Issues::People::UntrustedEmail if modifies?(:email)
      ret << Issues::People::UntrustedPhone if modifies?(:phone)
      ret
    end

    private

    def modifies?(*attributes)
      attributes.any? do |attribute|
        changed_attributes.include? attribute
      end
    end

    def changed_attributes
      @changed_attributes ||= person_data.keys.map(&:to_sym).to_set.freeze
    end
  end
end
