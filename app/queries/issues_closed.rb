# frozen_string_literal: true

class IssuesClosed < Rectify::Query
  def self.for
    new.query
  end

  def query
    Issue.where.not(closed_at: nil)
  end
end
