# frozen_string_literal: true

module Issues
  module People
    class UntrustedPhone < ProcedureIssue
      store_accessor :information, :phone
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
        phone = procedure.phone
        return false unless phone

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
