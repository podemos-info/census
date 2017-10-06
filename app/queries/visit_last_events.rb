# frozen_string_literal: true

class VisitLastEvents < Rectify::Query
  def self.for(visit)
    new(visit).query
  end

  def initialize(visit)
    @visit = visit
  end

  def query
    @visit.events.order(time: :desc).limit(10)
  end
end
