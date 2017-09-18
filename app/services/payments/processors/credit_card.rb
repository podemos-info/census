# frozen_string_literal: true

module Payments
  module Processors
    class CreditCard < Payments::Processor
      def process_batch(_orders_batch)
        yield
      end

      def process_order(order)
        payment_method = order.payment_method

        options = { currency: order.currency, order_id: format_order_id(order) }

        response = gateway.purchase(order.amount, payment_method.authorization_token, options)
        order.raw_response = response

        if response.success?
          payment_method.processed :ok
          order.charge
        else
          payment_method.processed parse_error_type(response)
          order.fail
        end
      end

      REQUIRED_EXTERNAL_PARAMS = [:person_id, :description, :amount, :raw_response, :authorization_token,
                                  :expiration_year, :expiration_month].freeze

      def parse_external_authorization_response(order, params)
        # check required keys presence (probably should be added by provider processor)
        return false unless (params.keys && REQUIRED_EXTERNAL_PARAMS) == REQUIRED_EXTERNAL_PARAMS

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

        if params[:error_type].present?
          order.payment_method.processed params[:error_type]
          order.fail
        else
          order.payment_method.processed :ok
          order.charge
        end
        true
      end
    end
  end
end
