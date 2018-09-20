# frozen_string_literal: true

module Issues
  module People
    class UntrustedEmail < ProcedureIssue
      class << self
        def build_for(procedure)
          new(
            role: Admin.roles[:data],
            level: :low,
            email: procedure.email
          )
        end

        def domains_blacklist
          @domains_blacklist ||= Set.new(Settings.procedures.untrusted_email.domains_blacklist)
        end
      end

      store_accessor :information, :email
      store_accessor :fix_information, :trusted, :comment

      def detect
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
          person.save!
          ::People::ChangesPublisher.full_status_changed!(person)
        end
      end

      def fixed_for?(issuable)
        super && trusted?
      end

      private

      def trusted?
        ActiveModel::Type::Boolean.new.cast(trusted)
      end

      def blacklisted?
        domain = procedure.email.split("@").last
        self.class.domains_blacklist.include? domain
      end
    end
  end
end
