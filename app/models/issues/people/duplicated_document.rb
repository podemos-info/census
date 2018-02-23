# frozen_string_literal: true

module Issues
  module People
    class DuplicatedDocument < ProcedureIssue
      store_accessor :information, :document_type, :document_scope_id, :document_id

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
        @affected_people ||= ::PeopleEnabled.for.merge(::PeopleWithDuplicatedDocument.for(self.class.document_information(procedure)))
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
