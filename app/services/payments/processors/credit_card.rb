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

      REQUIRED_EXTERNAL_PARAMS = [:person_id, :description, :amount, :raw_response, :authorization_token,
                                  :expiration_year, :expiration_month].freeze

      def parse_external_authorization_response(order, params)
        # check required keys presence (probably should be added by provider processor)
        return false unless (params.keys && REQUIRED_EXTERNAL_PARAMS) == REQUIRED_EXTERNAL_PARAMS

        fill_order order, params
        processed_order order: order, response_code: params[:response_code]
        params[:success?] ? order.charge : order.fail

        true
      end

      private

      def fill_order(order, params)
        order.person_id = params[:person_id]
        order.description = params[:description]
        order.amount = params[:amount]
        order.currency = params[:currency]
        order.raw_response = params[:raw_response]

        order.payment_method = ::PaymentMethods::CreditCard.new(
          payment_processor: params[:payment_processor],
          person_id: params[:person_id],
          authorization_token: params[:authorization_token],
          expiration_year: params[:expiration_year],
          expiration_month: params[:expiration_month]
        )
      end
    end
  end
end
