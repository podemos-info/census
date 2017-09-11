# frozen_string_literal: true

# The orders batch model.
class OrdersBatch < ApplicationRecord
  has_many :orders
  belongs_to :processed_by, class_name: "Person", optional: true

  def payment_processors
    orders.includes(:payment_methods).distinct(:payment_processor)
  end

  def orders_for_payment_processor(payment_processor)
    orders.includes(:payment_methods).where(payment_processor: payment_processor)
  end
end
