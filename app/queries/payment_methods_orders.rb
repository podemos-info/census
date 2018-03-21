# frozen_string_literal: true

class PaymentMethodsOrders < Rectify::Query
  def self.for(payment_methods:)
    new(payment_methods: payment_methods).query
  end

  def initialize(payment_methods:)
    @payment_methods = payment_methods
  end

  def query
    Order.where(payment_method: @payment_methods)
  end
end
