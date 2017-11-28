# frozen_string_literal: true

class OrdersBetweenDates < Rectify::Query
  def self.for(from_date, until_date)
    new(from_date, until_date).query
  end

  def initialize(from_date, until_date)
    @from_date = from_date.beginning_of_day
    @until_date = until_date.end_of_day
  end

  def query
    Order.where("orders.created_at BETWEEN ? AND ?", @from_date, @until_date)
  end
end
