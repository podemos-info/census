# frozen_string_literal: true

require_dependency "census/payments/redsys_integration"

module Payments
  module Processors
    class Redsys < CreditCard
      delegate :url_helpers, to: "Rails.application.routes"

      def gateway
        @gateway ||= ActiveMerchant::Billing::RedsysGateway.new(Settings.payments.processors.redsys.auth.to_h.merge!(signature_algorithm: "sha256"))
      end

      def parse_error_type(response)
        return :unknown unless response.params["ds_response"]
        error_type(response.params["ds_response"].to_i)
      end

      def external_authorization_params(order)
        integration_proxy.customer_id = order.person_id
        integration_proxy.product_description = order.description
        integration_proxy.amount = order.amount
        integration_proxy.currency = order.currency
        integration_proxy.return_url = order.payment_method.return_url
        integration_proxy.notification_url = url_helpers.callbacks_payments_url(:redsys)
        integration_proxy.form
      end

      def parse_external_authorization_response(order, params)
        params = integration_proxy.parse(params[:_body], Settings.payments.processors.redsys.notification_lifespan.minutes.ago)
        return false unless params

        params[:error_type] = error_type(integration_proxy.response_code) unless integration_proxy.success?

        params.merge!(
          payment_processor: :redsys,
          person_id: integration_proxy.customer_id,
          description: integration_proxy.product_description,
          amount: integration_proxy.amount,
          currency: integration_proxy.currency
        )
        super(order, params)
      end

      def format_external_authorization_response(result)
        integration_proxy.result = false unless result

        { xml: integration_proxy.format_response, content_type: "text/xml" }
      end

      private

      def integration_proxy
        @integration_proxy ||= begin
          settings = Settings.payments.processors.redsys.auth
          Census::Payments::RedsysIntegration.new(
            merchant_name: settings[:name],
            merchant_code: settings[:login],
            secret_key: settings[:secret_key],
            terminal: settings[:terminal],
            test: settings[:test],
            transaction_type: "0",
            default_language: I18n.default_locale,
            language: I18n.locale
          )
        end
      end

      def error_type(code)
        Settings.payments.processors.redsys.response_codes.each do |type, codes|
          return type if codes.include?(code)
        end
        :unknown
      end
    end
  end
end
