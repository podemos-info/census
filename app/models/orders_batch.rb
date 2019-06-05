# frozen_string_literal: true

class OrdersBatch < ApplicationRecord
  include ActiveJobReporter::HasJobs

  has_many :orders, dependent: :restrict_with_exception
  has_many :payment_methods, through: :orders

  belongs_to :processed_by, class_name: "Admin", optional: true

  has_paper_trail versions: { class_name: "Version" }
  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item
end
