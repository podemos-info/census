# frozen_string_literal: true

module Payments
  # A command to process an external authorization
  class ProcessExternalAuthorization < Rectify::Command
    # Public: Initializes the command.
    #
    # payment_processor - Payment processor that will handle the data received
    # params - Params received for the payment processor
    def initialize(payment_processor, params)
      @payment_processor_name = payment_processor
      @params = params
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when data request is valid. Include the response to be sent to the caller
    # - :invalid when the received data is invalid.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless params && order

      result = process_authorization
      broadcast(:ok, response: payment_processor.format_external_authorization_response(result))

      CheckPaymentIssuesJob.perform_later(issuable: order, admin: nil) if result
    end

    private

    def order
      @order ||= payment_processor.parse_external_authorization_response(@params)
    end

    def payment_processor
      @payment_processor ||= Payments::Processor.for(@payment_processor_name)
    end

    def process_authorization
      Order.transaction do
        Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: nil) do
          on(:invalid) { raise ActiveRecord::Rollback, "Invalid payment method information" }
          on(:error) { raise ActiveRecord::Rollback, "Error saving payment method" }
        end
        order.save!
        order.processed?
      end
    end
  end
end
