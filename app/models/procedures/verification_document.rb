# frozen_string_literal: true

module Procedures
  class VerificationDocument < Procedure
    def acceptable?
      true
    end

    def process_accept
      person.verified_by_document = true
    end

    def undo_accept
      person.verified_by_document = false
    end

    def persist_accept_changes!
      person.save!
    end
  end
end
