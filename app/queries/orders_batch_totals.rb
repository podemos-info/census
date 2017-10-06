# frozen_string_literal: true

class OrdersBatchTotals < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).query
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.orders.group("currency").pluck("currency, sum(amount) as amount")
  end
end
