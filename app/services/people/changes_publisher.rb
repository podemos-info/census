# frozen_string_literal: true

module People
  class ChangesPublisher
    class << self
      def full_status_changed!(person)
        Hutch.connect
        Hutch.publish "census.people.full_status_changed", person: person.qualified_id
      end
    end
  end
end
