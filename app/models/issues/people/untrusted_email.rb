# frozen_string_literal: true

module Issues
  module People
    class UntrustedEmail < ProcedureIssue
      store_accessor :information, :email
      store_accessor :fix_information, :trusted, :comment

      def detected?
        blacklisted?
      end

      def fill
        super
        self.people = [procedure.person]
      end

      def do_the_fix
        people.each do |person|
          next if trusted?
          person.send("fraud_detected")
          person.trash if person.enabled?
          person.save!
        end
      end

      def fixed_for?(issuable)
        super && trusted?
      end

      alias procedure issuable

      private

      def trusted?
        ActiveModel::Type::Boolean.new.cast(trusted)
      end

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
