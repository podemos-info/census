# frozen_string_literal: true

module Payments
  # A command to process an orders
  class ProcessOrder < Rectify::Command
    # Public: Initializes the command.
    #
    # order - Order to be processed
    # processed_by - The person that is processing the order
    def initialize(order, processed_by)
      @order = order
      @processed_by = processed_by
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the batch couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @order && @processed_by && @order.processable?

      payment_processor.process_order @order
      @order.assign_attributes processed_at: DateTime.now, processed_by: @processed_by

      result = Order.transaction do
        @order.save!
        :ok
      end

      broadcast result || :invalid
    end

    private

    def payment_processor
      @payment_processor ||= Payments::Processor.for(@order.payment_processor)
    end
  end
end
