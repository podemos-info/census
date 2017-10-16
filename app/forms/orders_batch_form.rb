# frozen_string_literal: true

# The form object that handles the data for an orders batch
class OrdersBatchForm < Form
  mimic :orders_batch

  attribute :description, String
  attribute :orders_from, Date
  attribute :orders_to, Date

  validates :description, :orders_from, :orders_to, presence: true

  def orders
    @orders ||= (OrdersWithoutOrdersBatch.new | OrdersPending.new | OrdersBetweenDates.new(orders_from, orders_to)).query
  end
end
