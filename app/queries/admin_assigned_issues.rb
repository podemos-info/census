# frozen_string_literal: true

class AdminAssignedIssues < Rectify::Query
  def self.for(admin)
    new(admin).query
  end

  def initialize(admin)
    @admin = admin
  end

  def query
    Issue.where(assigned_to: @admin)
  end
end
