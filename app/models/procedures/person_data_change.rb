# frozen_string_literal: true

module Procedures
  class PersonDataChange < PersonDataProcedure
    def acceptable?
      person.enabled?
    end

    def process_accept
      set_from_person_data
      person.assign_attributes(person_data)
    end

    def undo_accept
      person.assign_attributes(from_person_data)
    end

    def persist_accept_changes!
      person.save!
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
        value = person_data[attribute.to_s]
        value && value != person[attribute]
      end
    end
  end
end
