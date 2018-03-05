# frozen_string_literal: true

class IssuesOpen < Rectify::Query
  def self.for
    new.query
  end

  def query
    Issue.where(closed_at: nil)
  end
end
