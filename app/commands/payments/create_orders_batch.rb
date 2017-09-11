# frozen_string_literal: true

module Payments
  # A command to create a batch of orders to process
  class CreateOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # name - The name of the orders batch
    # orders - Orders to be included in the batch
    def initialize(description, orders)
      @description = description
      @orders = orders
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the batch couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @description && @orders && @orders.any?

      result = OrdersBatch.transaction do
        orders_batch.save!

        @orders.find_each do |order|
          order.orders_batch = orders_batch
          order.save!
        end

        :ok
      end

      broadcast result || :invalid
    end

    private

    def orders_batch
      @orders_batch ||= OrdersBatch.new description: @description
    end
  end
end
