# frozen_string_literal: true

class OrdersBatchTotalsPerType < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).query
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    orders.joins(:payment_method).group("payment_methods.type, currency").pluck("type, currency, sum(amount) as amount")
  end
end
