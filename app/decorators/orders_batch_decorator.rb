# frozen_string_literal: true

class OrdersBatchDecorator < ApplicationDecorator
  delegate_all

  def orders_count
    object.orders.count
  end

  def name
    object.description
  end
end
