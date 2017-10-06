# frozen_string_literal: true

class OrdersWithoutOrdersBatch < Rectify::Query
  def query
    Order.where(orders_batch: nil)
  end
end
