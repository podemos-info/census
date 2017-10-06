# frozen_string_literal: true

# The orders batch model.
class OrdersBatch < ApplicationRecord
  has_many :orders
  has_many :payment_methods, through: :orders

  belongs_to :processed_by, class_name: "Admin", optional: true

  has_paper_trail class_name: "Version"
  has_many :versions, as: :item
end
