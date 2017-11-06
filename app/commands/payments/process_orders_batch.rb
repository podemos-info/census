# frozen_string_literal: true

module Payments
  # A command to process a batch of orders
  class ProcessOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # orders_batch - Orders batch to be processed
    # current_admin - The person that is processing the orders batch
    def initialize(orders_batch:, admin:)
      @orders_batch = orders_batch
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :review if any order in the batch needs to be reviewed before processed.
    # - :invalid if the batch couldn't be processed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless orders_batch && admin
      return broadcast(:review) if OrdersBatchIssues.for(orders_batch).any?

      result = OrdersBatch.transaction do
        payment_results = OrdersBatchPaymentProcessors.for(orders_batch).map do |payment_processor|
          process_processor_batch_orders(Payments::Processor.for(payment_processor)) ? :ok : :issues
        end

        payment_results.member?(:issues) ? :issues : :ok
      end

      broadcast result || :invalid
    end

    private

    attr_reader :orders_batch, :admin

    def process_processor_batch_orders(processor)
      processor.process_batch orders_batch do
        OrdersBatchPaymentProcessorOrders.for(orders_batch, processor.name).find_each do |order|
          next unless order.processable?(inside_batch?: true)
          processor.process_order order
          Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: admin)
          order.update_attributes! processed_at: Time.now, processed_by: admin
          Issues::CheckProcessedOrderIssues.call(order: order, admin: admin)
        end
        orders_batch.update_attributes! processed_at: Time.now, processed_by: admin
      end
    end
  end
end
