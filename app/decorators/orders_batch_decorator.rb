# frozen_string_literal: true

class OrdersBatchDecorator < ApplicationDecorator
  delegate_all

  def name
    object.description
  end

  def orders_totals_text
    orders_totals.map { |totals| "#{totals[:full_amount]} (#{totals[:count]})" } .to_sentence
  end

  def orders_totals
    @orders_totals ||= OrdersBatchTotals.for(object).map do |currency, count, amount|
      { count: count, full_amount: Money.new(amount, currency).format }
    end
  end

  def orders_per_state
    @orders_per_state ||= OrdersBatchTotalsPerState.for(object).map do |state, currency, count, amount|
      { state: state, count: count, full_amount: Money.new(amount, currency).format }
    end
  end

  def orders_per_type
    @orders_per_type ||= OrdersBatchTotalsPerType.for(object).map do |payment_method_type, currency, count, amount|
      { payment_method: payment_method_type.constantize, count: count, full_amount: Money.new(amount, currency).format }
    end
  end

  def count_orders
    @count_orders ||= orders_totals.sum { |order_total| order_total[:count] }
  end
end
