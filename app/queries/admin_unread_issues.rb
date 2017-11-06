# frozen_string_literal: true

class AdminUnreadIssues < Rectify::Query
  def self.for(admin)
    new(admin).query
  end

  def initialize(admin)
    @admin = admin
  end

  def query
    Issue.joins(:issue_unreads).where("issue_unreads.admin_id" => @admin.id)
  end
end
