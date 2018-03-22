# frozen_string_literal: true

module Procedures
  class Registration < PersonDataProcedure
    def acceptable?
      person.can_register?
    end

    def process_accept
      person.assign_attributes(person_data)
      person.register
    end

    def undo_accept(saved: true)
      person.undo
      if saved
        self.person = person.paper_trail.previous_version
      else
        person.restore_attributes
      end
    end

    def process_reject
      person.reject if person.may_reject?
    end

    alias undo_reject undo_accept

    def persist_accept_changes!
      person.save!
    end

    alias persist_reject_changes! persist_accept_changes!

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
