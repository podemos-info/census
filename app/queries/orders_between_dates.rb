# frozen_string_literal: true

class OrdersBetweenDates < Rectify::Query
  def initialize(from_date, to_date)
    @from_date = from_date.beginning_of_day
    @to_date = to_date.end_of_day
  end

  def query
    Order.where("created_at BETWEEN ? AND ?", @from_date, @to_date)
  end
end
