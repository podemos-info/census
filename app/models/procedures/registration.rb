# frozen_string_literal: true

module Procedures
  class Registration < PersonDataProcedure
    def acceptable?
      person.can_register?
    end

    def process_accept
      set_from_person_data
      person.assign_attributes(person_data)
      person.register
    end

    def undo_accept
      person.assign_attributes(from_person_data)
      person.undo
    end

    def undo_reject
      person.undo
    end

    def process_reject
      person.reject if person.may_reject?
    end

    def persist_accept_changes!
      person.save!
    end

    def persist_reject_changes!
      person.save!
    end

    def possible_issues
      [
        Issues::People::DuplicatedDocument,
        Issues::People::DuplicatedPerson,
        Issues::People::UntrustedEmail,
        Issues::People::UntrustedPhone
      ]
    end
  end
end
