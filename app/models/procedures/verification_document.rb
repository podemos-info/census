# frozen_string_literal: true

module Procedures
  class VerificationDocument < Procedure
    def if_accepted
      person.verified_by_document = true
      ret = yield
      person.verified_by_document = false
      ret
    end

    def after_accepted
      person.verified_by_document = true
      person.save!
    end

    def undo
      person.verified_by_document = false
      person.save!
    end
  end
end

