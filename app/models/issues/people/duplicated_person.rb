# frozen_string_literal: true

module Issues
  module People
    class DuplicatedPerson < ProcedureIssue
      store_accessor :information, :born_at, :first_name, :last_name1, :last_name2

      def detected?
        affected_people.any?
      end

      def fill
        self.people = affected_people
        super
      end

      alias procedure issuable

      private

      def affected_people
        @affected_people ||= ::PeopleEnabled.for.merge(::PeopleByBornDate.for(born_at)).select do |person|
          normalize(person.first_name, person.last_name1, person.last_name2) == normalize(first_name, last_name1, last_name2)
        end
      end

      def normalize(*args)
        I18n.transliterate(args.map { |arg| Normalizr.normalize(arg, :strip, :blank, :downcase, :whitespace) }.compact.join(" "))
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
      end
    end
  end
end
