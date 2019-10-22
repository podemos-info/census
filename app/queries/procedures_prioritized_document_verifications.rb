# frozen_string_literal: true

class ProceduresPrioritizedDocumentVerifications < Rectify::Query
  def self.since(prioritized_at_limit)
    new(prioritized_at_limit).query
  end

  def initialize(prioritized_at_limit)
    @prioritized_at_limit = prioritized_at_limit
  end

  def query
    Procedures::DocumentVerification.pending.without_open_issues.where("prioritized_at > ?", @prioritized_at_limit).order(prioritized_at: :asc)
  end
end
