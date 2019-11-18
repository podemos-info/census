# frozen_string_literal: true

class Download < ApplicationRecord
  include Issuable

  mount_uploader :file, DownloadUploader
  belongs_to :person

  has_many :download_objects, dependent: :destroy
  has_many :orders_batches, -> { distinct }, through: :download_objects, source: :object, source_type: "OrdersBatch"
end
