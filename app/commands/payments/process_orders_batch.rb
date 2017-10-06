# frozen_string_literal: true

module Payments
  # A command to process a batch of orders
  class ProcessOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # orders_batch - Orders batch to be processed
    # processed_by - The person that is processing the orders batch
    def initialize(orders_batch, processed_by)
      @orders_batch = orders_batch
      @processed_by = processed_by
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the batch couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @orders_batch && @processed_by

      result = OrdersBatch.transaction do
        payment_results = OrdersBatchPaymentProcessors.for(@orders_batch).map do |payment_processor|
          process_processor_batch_orders(Payments::Processor.for(payment_processor)) ? :ok : :issues
        end

        payment_results.member?(:issues) ? :issues : :ok
      end

      broadcast result || :invalid
    end

    private

    def process_processor_batch_orders(processor)
      processor.process_batch @orders_batch do
        OrdersBatchPaymentProcessorOrders.for(@orders_batch, processor.name).find_each do |order|
          next unless order.processable?(true)
          processor.process_order order
          order.update_attributes! processed_at: DateTime.now, processed_by: @processed_by
        end
        @orders_batch.update_attributes! processed_at: DateTime.now, processed_by: @processed_by
      end
    end
  end
end
