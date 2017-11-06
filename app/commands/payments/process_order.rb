# frozen_string_literal: true

module Payments
  # A command to process an order
  class ProcessOrder < Rectify::Command
    # Public: Initializes the command.
    #
    # order - Order to be processed
    # admin - The admin user processing the order
    def initialize(order:, admin:)
      @order = order
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the order couldn't be processed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless order && admin && order.processable?(inside_batch?: false)

      payment_processor.process_order order
      @order.assign_attributes processed_at: Time.now, processed_by: admin

      result = Order.transaction do
        Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: admin)
        order.save!
        Issues::CheckProcessedOrderIssues.call(order: order, admin: admin)

        :ok
      end

      broadcast result || :invalid
    end

    private

    attr_reader :order, :admin

    def payment_processor
      @payment_processor ||= Payments::Processor.for(order.payment_processor)
    end
  end
end
