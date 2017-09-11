# frozen_string_literal: true

module Payments
  module Processors
    class CreditCard < Payments::Processor
      def process_batch!(_orders_batch)
        yield
      end

      def process_order!(order)
        payment_method = order.payment_method

        options = { currency: order.currency }
        if payment_method.authorized?
          credit_card = payment_method.authorization_token
        else
          credit_card = create_credit_card(order, payment_method)
          options[:store] = true
          return false if credit_card.valid?
        end

        options[:order_id] = format_order_id(order)

        response = gateway.purchase(order.amount, credit_card, options)

        # guardar response.message
        if response.success?
          payment_method.authorization_token = parse_authorization_token(response)
          payment_method.processed_ok!
        else
          error_type = parse_error_type(response)
          case error_type
          when :warning
            payment_method.processed_warn
          when :error
            payment_method.processed_error
          when :system
            #TO-DO: avisar a admin
          else
            #TO-DO: desconocido!
          end
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
        order.raw_response = params[:raw_response]

        order.payment_method = ::PaymentMethods::CreditCard.new(
          authorization_token: params[:authorization_token],
          expiration_year: params[:expiration_year],
          expiration_month: params[:expiration_month]
        )
        order.payment_method.processed_ok
        true
      end

      private

      def create_credit_card(order, payment_method)
        decorated_person = order.person.decorate
        ActiveMerchant::Billing::CreditCard.new(
          number: payment_method.card_number,
          verification_value: payment_method.ccv,
          year: payment_method.expiration_year.to_s,
          month: payment_method.expiration_month.to_s,
          first_name: decorated_person.first_name,
          last_name: decorated_person.last_names
        )
      end
    end
  end
end
