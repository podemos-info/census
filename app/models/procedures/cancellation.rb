# frozen_string_literal: true

module Procedures
  class Cancellation < Procedure
    store_accessor :information, :reason

    def acceptable?
      !person.deleted?
    end

    def process_accept
      person.deleted_at = Time.now
    end

    def undo_accept
      person.deleted_at = nil
    end

    def persist_accept_changes!
      if person.deleted_at.nil?
        person.restore
      else
        person.destroy
      end
    end
  end
end
