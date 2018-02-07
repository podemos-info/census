# frozen_string_literal: true

module Payments
  # A command to process an order
  class ProcessOrder < Rectify::Command
    # Public: Initializes the command.
    #
    # order - Order to be processed
    # admin - The admin user processing the order
    def initialize(order:, admin: nil)
      @order = order
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when the order is not processable individually.
    # - :error if the order couldn't be processed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless order&.processable?(inside_batch?: false)

      broadcast process_order
    end

    private

    attr_reader :order, :admin

    def payment_processor
      @payment_processor ||= Payments::Processor.for(order.payment_processor)
    end

    def process_order
      payment_processor.process_order order
      order.assign_attributes processed_at: Time.now, processed_by: admin

      return :error unless save_all

      check_issues
    end

    def save_all
      save_payment_method && save_order
    end

    def save_payment_method
      ret = false
      Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: admin) do
        on(:invalid) { raise Census::Payments::UnrecoverableError, "Invalid payment method information for processed order" }
        on(:error) { raise Census::Payments::UnrecoverableError, "Error saving payment method for processed order" }
        on(:ok) { ret = true }
      end
      ret
    rescue StandardError => error
      Census::Payments.handle_order_unrecoverable_error(order: order, error: error, action: "saving payment method")
      false
    end

    def save_order
      order.save!
      true
    rescue StandardError => error
      Census::Payments.handle_order_unrecoverable_error(order: order, error: error, action: "saving order")
      false
    end

    def check_issues
      ret = :order_issues
      Issues::CheckProcessedOrderIssues.call(order: order, admin: admin) do
        on(:new_issue) {}
        on(:existing_issue) {}
        on(:fixed_issue) { ret = :ok }
        on(:ok) { ret = :ok }
      end
      ret
    end
  end
end
