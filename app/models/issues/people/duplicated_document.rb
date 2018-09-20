# frozen_string_literal: true

module Issues
  module People
    class DuplicatedDocument < ProcedureIssue
      class << self
        def build_for(procedure)
          new(
            role: Admin.roles[:data],
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

        def causes
          [:mistake, :fraud]
        end
      end

      store_accessor :information, :document_type, :document_scope_id, :document_id
      store_accessor :fix_information, :chosen_person_id, :cause, :comment

      validates :cause, inclusion: { in: causes.flat_map { |s| [s, s.to_s] } }, if: :fixing
      validate :validate_chosen_person_id, if: :fixing

      def detect
        affected_people.count { |person| person.enabled? || person.pending? } > 1
      end

      def fill
        super
        self.people = (affected_people + people).uniq
      end

      def do_the_fix
        people.each do |person|
          next if chosen_person_id == person.id

          person.send("#{cause}_detected")
          person.save!
          ::People::ChangesPublisher.full_status_changed!(person)
        end
      end

      def fixed_for?(issuable)
        super && (
          (issuable.is_a?(Procedure) && chosen_person_id == issuable.person_id) ||
          (issuable.is_a?(Person) && chosen_person_id == issuable.id)
        )
      end

      private

      def affected_people
        @affected_people ||= (::PeopleEnabled.for.merge(::PeopleWithDuplicatedDocument.for(self.class.document_information(procedure))) + [procedure.person]).uniq
      end

      def chosen_person_id
        @chosen_person_id ||= fix_information["chosen_person_id"]&.to_i
      end

      def validate_chosen_person_id
        errors.add(:chosen_person_id, :not_affected_person) unless person_ids.include?(chosen_person_id)
      end
    end
  end
end
