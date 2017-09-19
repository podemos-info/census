# frozen_string_literal: true

module Payments
  class Processor
    def format_order_id(order)
      order.date.strftime("%y%m%d") + (order.id % 1_000_000).to_s.rjust(6, "0")
    end

    def self.for(name)
      "payments/processors/#{name}".camelize.constantize.new
    end
  end
end
