# frozen_string_literal: true

class IssuesNonFixed < Rectify::Query
  def self.for
    new.query
  end

  def query
    Issue.where(fixed_at: nil)
  end
end
