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
        processed_at = DateTime.now

        payment_processors.each do |payment_processor|
          payment_processor.process_batch! @orders_batch do
            @orders_batch.orders_for_payment_processor(payment_processor).find_each do |order|
              next unless order.processable?
              payment_processor.process_order! order
              order.update_attributes! processed_at: processed_at, processed_by: @processed_by
            end
          end
          @orders_batch.update_attributes! processed_at: processed_at, processed_by: @processed_by
        end

        :ok
      end

      broadcast result || :invalid
    end

    private

    def payment_processors
      @payment_processors ||= @orders_batch.payment_processors.map { |processor| Payments::Processor.for(processor) }
    end
  end
end
