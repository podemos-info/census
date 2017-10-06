# frozen_string_literal: true

class OrdersBatchTotalsPerState < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).query
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.orders.group("state, currency").pluck("state, currency, sum(amount) as amount")
  end
end
