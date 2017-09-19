# frozen_string_literal: true

# The orders batch model.
class OrdersBatch < ApplicationRecord
  has_many :orders
  has_many :payment_methods, through: :orders

  belongs_to :processed_by, class_name: "Person", optional: true

  def payment_processors
    orders.joins(:payment_method).distinct(:payment_processor).pluck(:payment_processor)
  end

  def orders_for_payment_processor(payment_processor)
    orders.joins(:payment_method).where(payment_methods: { payment_processor: payment_processor })
  end
end
