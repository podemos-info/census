# frozen_string_literal: true

module Procedures
  class Cancellation < Procedure
    store_accessor :information, :reason

    def acceptable?
      !person.discarded?
    end

    def process_accept
      person.discarded_at = Time.zone.now
    end

    def undo_accept(**_args)
      person.discarded_at = nil
    end

    def persist_accept_changes!
      person.save!
    end
  end
end
