# frozen_string_literal: true

module Payments
  module Processors
    class CreditCard < Payments::Processor
      def process_batch(_orders_batch)
        yield
        true
      end

      def process_order(order)
        payment_method = order.payment_method

        options = { currency: order.currency, order_id: format_order_id(order) }

        response = gateway.purchase(order.amount, payment_method.authorization_token, options)
        order.raw_response = response
        processed_order order: order, response_code: get_response_code(response)
        response.success? ? order.charge : order.fail
      end

      REQUIRED_EXTERNAL_PARAMS = [:order_id, :description, :amount, :raw_response, :authorization_token,
                                  :expiration_year, :expiration_month].freeze

      def parse_external_authorization_response(params)
        # check required keys presence (probably should be added by provider processor)
        return false unless (params.keys && REQUIRED_EXTERNAL_PARAMS) == REQUIRED_EXTERNAL_PARAMS

        order = Order.find(params[:order_id])
        order.assign_attributes params.slice(:description, :amount, :currency, :raw_response)
        order.payment_method.assign_attributes params.slice(:authorization_token, :expiration_year, :expiration_month)
        order.payment_method.default_name # force payment method to update its name with its expiration date

        processed_order order: order, response_code: params[:response_code]
        params[:success?] ? order.charge : order.fail

        order
      end
    end
  end
end
