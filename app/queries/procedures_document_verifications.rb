# frozen_string_literal: true

class ProceduresDocumentVerifications < Rectify::Query
  def query
    Procedures::DocumentVerification.pending.without_open_issues.order(prioritized_at: :asc, created_at: :asc)
  end
end
