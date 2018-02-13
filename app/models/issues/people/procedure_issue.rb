# frozen_string_literal: true

module Issues
  module People
    class ProcedureIssue < Issue
      def fill
        people << procedure.person
        self.procedures = [procedure]
      end

      class << self
        def find_for(procedure)
          merge(procedure.issues).first
        end
      end
    end
  end
end
