# frozen_string_literal: true

# The form object that handles the data for an orders batch
class OrdersBatchForm < Form
  mimic :orders_batch

  attribute :description, String
  attribute :orders, Array

  validates :description, :orders, presence: true
  validates :orders, length: { minimum: 1 }
end
