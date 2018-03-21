# frozen_string_literal: true

module Issues
  module People
    class ProcedureIssue < Issue
      def fill
        self.procedures = [procedure]
      end

      def post_close(admin)
        procedures.each do |procedure|
          ::UpdateProcedureJob.perform_later(procedure: procedure, admin: admin)
        end
      end

      class << self
        def find_for(procedure)
          merge(procedure.issues).first
        end
      end
    end
  end
end
