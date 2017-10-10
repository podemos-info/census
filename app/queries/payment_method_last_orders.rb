# frozen_string_literal: true

class PaymentMethodLastOrders < Rectify::Query
  def self.for(payment_method)
    new(payment_method).query
  end

  def initialize(payment_method)
    @payment_method = payment_method
  end

  def query
    @payment_method.orders.order(created_at: :desc).limit(3)
  end
end
