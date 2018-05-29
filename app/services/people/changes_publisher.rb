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
      return { person: person.qualified_id, state: person.state, verification: person.verification } if person.discarded?

      {
        person: person.qualified_id,
        state: person.state,
        membership_level: person.membership_level,
        verification: person.verification,
        scope: person.scope&.code
      }
    end
  end
end
