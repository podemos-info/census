# frozen_string_literal: true

module Issues
  module People
    class DuplicatedVerifiedPhone < ProcedureIssue
      class << self
        def build_for(procedure)
          new(
            role: Admin.roles[:data],
            level: :medium,
            phone: procedure.phone
          )
        end

        def fix_attributes
          [:comment, chosen_person_ids: []]
        end
      end

      store_accessor :information, :phone
      store_accessor :fix_information, :chosen_person_ids, :comment

      validate :validate_chosen_person_ids, if: :fixing

      def fill
        super
        self.people = (affected_people + people).uniq
      end

      def detect
        affected_people.count > 1
      end

      def do_the_fix
        fix_verified_people
        fix_not_verified_people
      end

      def fixed_for?(issuable)
        super && (
          (issuable.is_a?(Procedure) && chosen_person_ids.include?(issuable.person_id)) ||
          (issuable.is_a?(Person) && chosen_person_ids.include?(issuable.id))
        )
      end

      private

      def affected_people
        @affected_people ||= (affected_people_with_verified_phone + affected_people_without_verified_phone + [procedure.person]).uniq
      end

      def affected_people_with_verified_phone
        @affected_people_with_verified_phone ||= ::PeopleEnabled.for.merge(::PeopleByVerifiedPhone.for(phone))
      end

      def affected_people_without_verified_phone
        @affected_people_without_verified_phone ||= ::PeopleEnabled.for.merge(::PeopleWithoutVerifiedPhoneByUsedPhone.for(phone))
      end

      def chosen_person_ids
        @chosen_person_ids ||= fix_information["chosen_person_ids"]&.map(&:to_i) || []
      end

      def validate_chosen_person_ids
        errors.add(:chosen_person_ids, :not_affected_person) unless chosen_person_ids.all? { |chosen_person_id| person_ids.include?(chosen_person_id) }
      end

      def fix_verified_people
        affected_people_with_verified_phone.each do |person|
          next if chosen_person_ids.include?(person.id)

          person.reassign_phone
          person.save!
        end
      end

      def fix_not_verified_people
        affected_people_without_verified_phone.each do |person|
          next if chosen_person_ids.include?(person.id)

          person.fraud_detected
          person.save!
        end
      end
    end
  end
end
