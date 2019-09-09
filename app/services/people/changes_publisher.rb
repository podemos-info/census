# frozen_string_literal: true

module People
  class ChangesPublisher
    include Singleton

    class << self
      delegate :full_status_changed!, to: :instance
    end

    def full_status_changed!(person)
      Hutch.connect
      Hutch.publish "census.people.full_status_changed", **person_full_status(person)
    end

    private

    def person_full_status(person)
      full_status = { person: person.qualified_id, external_ids: person.external_ids, state: person.state, verification: person.verification }

      return full_status if person.discarded?

      full_status.update(
        membership_level: person.membership_level,
        scope_code: person.scope&.code,
        document_type: person.document_type,
        age: person.age
      )
    end
  end
end
