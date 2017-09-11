# frozen_string_literal: true

class OrdersBatchDecorator < Draper::Decorator
  delegate_all

  def orders_count
    object.orders.count
  end

  def to_s
    object.description
  end

  def name
    object.description
  end
end
