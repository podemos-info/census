# frozen_string_literal: true

class AdminIssues < Rectify::Query
  def self.for(admin)
    new(admin).query
  end

  def initialize(admin)
    @admin = admin
  end

  def query
    Issue.where(role: @admin.role).or(Issue.where(assigned_to_id: @admin.person_id))
  end
end
