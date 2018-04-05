# frozen_string_literal: true

module Procedures
  class DocumentVerification < Procedure
    def acceptable?
      person.enabled?
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

    def persist_accept_changes!
      person.save!
    end
  end
end
