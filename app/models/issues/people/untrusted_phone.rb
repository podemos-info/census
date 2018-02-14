# frozen_string_literal: true

module Issues
  module People
    class UntrustedPhone < ProcedureIssue
      store_accessor :information, :phone

      def detected?
        blacklisted?
      end

      alias procedure issuable

      private

      def blacklisted?
        phone = procedure.phone
        self.class.phones_blacklist.include?(phone) || (1..phone.size - 1).any? { |i| self.class.prefixes_blacklist.include?(phone[0, i]) }
      end

      class << self
        def build_for(procedure)
          UntrustedPhone.new(
            role: Admin.roles[:lopd],
            level: :low,
            phone: procedure.phone
          )
        end

        def prefixes_blacklist
          @prefixes_blacklist ||= Set.new(Settings.procedures.untrusted_phone.prefixes_blacklist)
        end

        def phones_blacklist
          @phones_blacklist ||= Set.new(Settings.procedures.untrusted_phone.phones_blacklist)
        end
      end
    end
  end
end
