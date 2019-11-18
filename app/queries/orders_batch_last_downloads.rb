# frozen_string_literal: true

class OrdersBatchLastDownloads < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).query
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    @orders_batch.downloads.order(created_at: :desc).kept.limit(3)
  end
end
