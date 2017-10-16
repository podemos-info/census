# frozen_string_literal: true

class OrdersBatchTotals < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).values
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.orders.reorder(nil).group("currency")
  end

  def values
    query.pluck("currency, count(id) as count, sum(amount) as amount")
  end
end
