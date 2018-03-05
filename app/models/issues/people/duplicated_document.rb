# frozen_string_literal: true

module Issues
  module People
    class DuplicatedDocument < ProcedureIssue
      store_accessor :information, :document_type, :document_scope_id, :document_id
      store_accessor :fix_information, :chosen_person_id, :comment

      def detected?
        affected_people.any?
      end

      def fill
        super
        self.people = affected_people
        people << procedure.person
      end

      def fix!
        check_chosen_person_id

        people.each do |person|
          person.ban! if person.enabled? && chosen_person_id != person.id
        end

        super
      end

      def fixed_for?(issuable)
        super && (
          (issuable.is_a?(Procedure) && chosen_person_id == issuable.person_id) ||
          (issuable.is_a?(Person) && chosen_person_id == issuable.id)
        )
      end

      alias procedure issuable

      private

      def affected_people
        @affected_people ||= ::PeopleEnabled.for.merge(::PeopleWithDuplicatedDocument.for(self.class.document_information(procedure)))
      end

      def chosen_person_id
        @chosen_person_id ||= fix_information["chosen_person_id"]&.to_i
      end

      def check_chosen_person_id
        raise "Chosen person is not in the list of affected people" unless person_ids.include?(chosen_person_id)
      end

      class << self
        def build_for(procedure)
          DuplicatedDocument.new(
            role: Admin.roles[:lopd],
            level: :medium,
            **document_information(procedure)
          )
        end

        def document_information(procedure)
          {
            document_type: procedure.document_type,
            document_scope_id: procedure.document_scope_id,
            document_id: procedure.document_id
          }
        end
      end
    end
  end
end
