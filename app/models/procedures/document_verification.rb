# frozen_string_literal: true

module Procedures
  class DocumentVerification < Procedure
    def acceptable?
      person.enabled? && person.may_verify?
    end

    def self.auto_processable?
      false
    end

    def process_accept
      person.verify
    end

    def undo_accept
      person.undo_verification
    end

    def persist_changes!
      return unless person.has_changes_to_save?

      person.save!
      ::People::ChangesPublisher.full_status_changed!(person)
    end

    def process_reject
      person.request_verification
    end
  end
end
