# frozen_string_literal: true

class OrdersBatchTotalsPerType < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).values
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.orders.reorder(nil).joins(:payment_method).group("payment_methods.type, currency")
  end

  def values
    query.pluck("type, currency, count(orders.id) as count, sum(amount) as amount")
  end
end
