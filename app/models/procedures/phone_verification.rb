# frozen_string_literal: true

module Procedures
  class PhoneVerification < Procedure
    store_accessor :information, :phone

    def acceptable?
      person.enabled?
    end

    def self.auto_processable?
      true
    end

    def process_accept
      person.phone = phone
      person.verify_phone
    end

    def undo_accept
      person.unverify_phone
    end

    def persist_changes!
      return unless person.has_changes_to_save?

      person.save!
    end

    def possible_issues
      ret = []
      ret << Issues::People::DuplicatedVerifiedPhone unless person.verified?
      ret << Issues::People::UntrustedPhone if phone.present?
      ret
    end

    def fast_filter_contents
      [phone] + super
    end
  end
end
