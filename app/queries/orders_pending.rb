# frozen_string_literal: true

class OrdersPending < Rectify::Query
  def query
    Order.pending.order(created_at: :asc)
  end
end
