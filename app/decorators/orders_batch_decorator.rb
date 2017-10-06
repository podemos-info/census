# frozen_string_literal: true

class OrdersBatchDecorator < ApplicationDecorator
  delegate_all

  def orders_count
    object.orders.count
  end

  def name
    object.description
  end

  def orders_totals
    @orders_totals ||= OrdersBatchTotals.for(object).map { |currency, amount| Money.new(amount, currency).format }
  end

  def orders_per_state
    @orders_per_state ||= OrdersBatchTotalsPerState.for(object).map do |state, currency, amount|
      { state: state, full_amount: Money.new(amount, currency).format }
    end
  end

  def orders_per_type
    @orders_per_type ||= OrdersBatchTotalsPerType.for(object).map do |payment_method_type, currency, amount|
      { payment_method: payment_method_type.constantize, full_amount: Money.new(amount, currency).format }
    end
  end

  def count_orders
    @count_orders ||= object.orders.count
  end
end
