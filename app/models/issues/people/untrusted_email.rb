# frozen_string_literal: true

module Issues
  module People
    class UntrustedEmail < ProcedureIssue
      store_accessor :information, :email

      def detected?
        blacklisted?
      end

      alias procedure issuable

      private

      def blacklisted?
        domain = procedure.email.split("@").last
        self.class.domains_blacklist.include? domain
      end

      class << self
        def build_for(procedure)
          UntrustedEmail.new(
            role: Admin.roles[:lopd],
            level: :low,
            email: procedure.email
          )
        end

        def domains_blacklist
          @domains_blacklist ||= Set.new(Settings.procedures.untrusted_email.domains_blacklist)
        end
      end
    end
  end
end
