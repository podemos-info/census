# frozen_string_literal: true

module Procedures
  class Cancellation < Procedure
    store_accessor :information, :reason, :from_state

    def acceptable?
      !person.discarded?
    end

    def process_accept
      self.from_state = person.state
      person.discarded_at = Time.zone.now
      person.cancel
    end

    def undo_accept
      person.discarded_at = nil
      person.state = from_state
    end

    def persist_accept_changes!
      person.save!
    end
  end
end
