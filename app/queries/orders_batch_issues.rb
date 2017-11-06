# frozen_string_literal: true

class OrdersBatchIssues < Rectify::Query
  def self.for(orders_batch)
    new(orders_batch).query
  end

  def initialize(orders_batch)
    @orders_batch = orders_batch
  end

  def query
    Issue.joins(:payment_methods).merge(@orders_batch.payment_methods)
  end
end
