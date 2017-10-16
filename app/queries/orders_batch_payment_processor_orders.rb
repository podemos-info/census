# frozen_string_literal: true

class OrdersBatchPaymentProcessorOrders < Rectify::Query
  def self.for(orders_batch, payment_processor)
    new(orders_batch, payment_processor).query
  end

  def initialize(orders_batch, payment_processor)
    @orders_batch = orders_batch
    @payment_processor = payment_processor
  end

  def query
    @orders_batch.orders.joins(:payment_method).where(payment_methods: { payment_processor: @payment_processor })
  end
end
