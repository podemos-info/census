# frozen_string_literal: true

class OrdersBatch < ApplicationRecord
  include ActiveJobReporter::HasJobs
  include HasDownloads

  has_many :orders, dependent: :restrict_with_exception
  has_many :payment_methods, through: :orders
  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item

  belongs_to :processed_by, class_name: "Admin", optional: true

  has_paper_trail versions: { class_name: "Version" }
end
