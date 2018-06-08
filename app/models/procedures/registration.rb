# frozen_string_literal: true

module Procedures
  class Registration < PersonDataProcedure
    delegate :external_ids, to: :person_data_object

    def acceptable?
      person.may_accept?
    end

    def process_accept
      person.assign_attributes(person_data)
      self.from_person_data = person.changed_attributes
      person.accept
    end

    def undo_accept
      person.assign_attributes(from_person_data)
      person.undo
    end

    def undo_reject
      person.undo
    end

    def process_reject
      person.trash
    end

    def persist_changes!
      return unless person.has_changes_to_save?
      person.save!
      ::People::ChangesPublisher.full_status_changed!(person)
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
