# frozen_string_literal: true

class OrdersBatchPaymentProcessors < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).values
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.orders.joins(:payment_method).distinct(:payment_processor)
  end

  def values
    query.pluck(:payment_processor)
  end
end
