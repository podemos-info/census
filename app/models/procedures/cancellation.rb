# frozen_string_literal: true

module Procedures
  class Cancellation < Procedure
    store_accessor :information, :channel, :reason, :from_state

    def acceptable?
      !person.discarded?
    end

    def process_accept
      self.from_state = person.state
      person.cancel
    end

    def undo_accept
      person.discarded_at = nil
      person.state = from_state
    end

    def persist_changes!
      return unless person.has_changes_to_save?

      person.save!
      ::People::ChangesPublisher.full_status_changed!(person)
      send_affiliation_change_email
    end

    private

    def send_affiliation_change_email
      if person.member?
        PeopleMailer.with(person: person)
                    .unaffiliated.deliver_later(wait: undo_minutes)
      end
    end
  end
end
