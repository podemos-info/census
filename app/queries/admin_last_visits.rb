# frozen_string_literal: true

class AdminLastVisits < Rectify::Query
  def self.for(admin)
    new(admin).query
  end

  def initialize(admin)
    @admin = admin
  end

  def query
    @admin.visits.reorder(started_at: :desc).limit(3)
  end
end
