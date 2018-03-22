# frozen_string_literal: true

module Issues
  module People
    class DuplicatedPerson < ProcedureIssue
      store_accessor :information, :born_at, :first_name, :last_name1, :last_name2
      store_accessor :fix_information, :chosen_person_ids, :comment

      def detected?
        affected_people.count { |person| person.enabled? || person.pending? } > 1
      end

      def fill
        super
        self.people = (affected_people + people).uniq
      end

      def fix!
        return false unless valid_fix_information?

        people.each do |person|
          person.ban! if person.enabled? && !chosen_person_ids.include?(person.id)
        end

        super
      end

      def fixed_for?(issuable)
        super && (
          (issuable.is_a?(Procedure) && chosen_person_ids.include?(issuable.person_id)) ||
          (issuable.is_a?(Person) && chosen_person_ids.include?(issuable.id))
        )
      end

      alias procedure issuable

      private

      def affected_people
        @affected_people ||= (
          ::PeopleEnabled.for.merge(::PeopleByBornDate.for(born_at)).select do |person|
            normalize(person.first_name, person.last_name1, person.last_name2) == normalize(first_name, last_name1, last_name2)
          end + [procedure.person]
        ).uniq
      end

      def normalize(*args)
        I18n.transliterate(args.map { |arg| Normalizr.normalize(arg, :strip, :blank, :downcase, :whitespace) }.compact.join(" "))
      end

      def chosen_person_ids
        @chosen_person_ids ||= fix_information["chosen_person_ids"]&.map(&:to_i) || []
      end

      def valid_fix_information?
        if chosen_person_ids.all? { |chosen_person_id| person_ids.include?(chosen_person_id) }
          true
        else
          errors.add(:chosen_person_ids, :not_affected_person)
          false
        end
      end

      class << self
        def build_for(procedure)
          DuplicatedPerson.new(
            role: Admin.roles[:lopd],
            level: :low,
            born_at: procedure.born_at,
            first_name: procedure.first_name,
            last_name1: procedure.last_name1,
            last_name2: procedure.last_name2
          )
        end

        def fix_attributes
          [:comment, chosen_person_ids: []]
        end
      end
    end
  end
end
