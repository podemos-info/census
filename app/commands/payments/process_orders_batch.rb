# frozen_string_literal: true

module Payments
  # A command to process a batch of orders
  class ProcessOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # orders_batch - Orders batch to be processed
    # admin - The person that is processing the orders batch
    def initialize(orders_batch:, admin:)
      @orders_batch = orders_batch
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when the orders batch was processed.
    # - :invalid when the given data is invalid.
    # - :review if any order in the batch needs to be reviewed before processed.
    #
    # Each order processing broadcasts one of these events and the order itself as a param:
    # - :order_ok when the order was processed ok.
    # - :unprocessable_order when the order can't be processed.
    # - :payment_method_error when the payment method couldn't be saved.
    # - :order_issues when the order was processed but there were issues on this process.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless valid?
      return broadcast(:review) if review?

      orders_batch.update_attributes! processed_at: Time.now, processed_by: admin

      result = :ok
      OrdersBatchPaymentProcessors.for(orders_batch).each do |payment_processor|
        processor = Payments::Processor.for(payment_processor)
        processor_result = processor.process_batch(orders_batch) do
          process_orders(processor, orders_batch)
        end
        broadcast("processor_#{processor_result}", processor: payment_processor)
        result = :error unless processor_result == :ok
      end

      broadcast result
    end

    private

    attr_reader :orders_batch, :admin

    def valid?
      orders_batch && admin
    end

    def review?
      OrdersBatchIssues.for(orders_batch).merge(IssuesNonFixed.for).any?
    end

    def process_orders(processor, orders_batch)
      errors_count = 0
      OrdersBatchPaymentProcessorOrders.for(orders_batch, processor.name).find_each do |order|
        order_result = process_order(processor, order)

        errors_count += 1 if order_result == :order_error

        broadcast(order_result, order: order)

        return false if errors_count >= Settings.payments.orders_batch_processing_errors_limit
      end
      true
    end

    def process_order(processor, order)
      return :unprocessable_order unless order.processable?(inside_batch?: true)

      processor.process_order order
      order.assign_attributes processed_at: Time.now, processed_by: admin

      return :order_error unless save_all(order)

      check_issues(order)
    end

    def save_all(order)
      save_payment_method(order) && save_order(order)
    end

    def save_payment_method(order)
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

    def save_order(order)
      order.save!
      true
    rescue StandardError => error
      Census::Payments.handle_order_unrecoverable_error(order: order, error: error, action: "saving order")
      false
    end

    def check_issues(order)
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
