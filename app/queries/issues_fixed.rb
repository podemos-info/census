# frozen_string_literal: true

class IssuesFixed < Rectify::Query
  def self.for
    new.query
  end

  def query
    Issue.where.not(fixed_at: nil)
  end
end
