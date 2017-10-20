# frozen_string_literal: true

module Census
  module Payments
    class RedsysIntegration < Rectify::Form
      LIVE_URL = "https://sis.sermepa.es/sis/realizarPago"
      TEST_URL = "https://sis-t.redsys.es:25443/sis/realizarPago"
      SIGNATURE_VERSION = "HMAC_SHA256_V1"
      CURRENCY_CODES_BACK = ActiveMerchant::Billing::RedsysGateway::CURRENCY_CODES.invert.freeze

      LANGUAGES = { es: "001", en: "002", ca: "003", fr: "004", de: "005", nl: "006", it: "007", sv: "008",
                    pt: "009", pl: "011", gl: "012", eu: "013" }.freeze

      attribute :merchant_name, String
      attribute :merchant_code, String
      attribute :terminal, String
      attribute :secret_key, String
      attribute :test, Boolean, default: true
      attribute :transaction_type, String, default: "0"

      attribute :notification_url, String
      attribute :return_url, String

      attribute :customer_id, Integer
      attribute :product_description, String
      attribute :amount, Integer
      attribute :currency, String
      attribute :language, Symbol

      attribute :response_code, String
      attribute :document_literal_style, Boolean

      validates :merchant_name, :merchant_code, :terminal, :secret_key, :test, :transaction_type, presence: true
      validates :notification_url, :return_url, presence: true
      validates :customer_id, :amount, presence: true

      def form
        return nil if invalid?

        {
          action: test ? TEST_URL : LIVE_URL,
          fields: {
            Ds_MerchantParameters: params,
            Ds_SignatureVersion: SIGNATURE_VERSION,
            Ds_Signature: mac256(order_key, params)
          }
        }
      end

      def parse(response, date_limit)
        # By default use raw response as response code
        self.response_code = response

        response_parts = parse_response(response)
        return nil unless response_parts

        request = response_parts[:request]

        self.order_id = request["Ds_Order"]
        self.amount = request["Ds_Amount"].to_i
        self.currency_code = request["Ds_Currency"]
        self.product_description = request["Ds_MerchantData"]
        self.merchant_code = request["Ds_MerchantCode"]
        self.terminal = request["Ds_Terminal"]

        return nil unless valid_datetime?(request, date_limit) && valid_signature?(response_parts[:message]["Signature"], response_parts[:raw_request])

        self.response_code = request["Ds_Response"]
        return { raw_response: request } unless success?

        {
          authorization_token: request["Ds_Merchant_Identifier"],
          expiration_year: "20#{request["Ds_ExpiryDate"][0..1]}".to_i,
          expiration_month: request["Ds_ExpiryDate"][2..3].to_i,
          raw_response: request
        }
      end

      def format_response
        return nil unless response_code.present? # only can be used to respond parsed responses

        envelope(response_message)
      end

      def success?
        return nil unless response_code&.to_i
        @success ||= response_code.to_i <= 100 || %w(0400 0481 0500 0900).include?(response_code)
      end

      private

      def params
        Base64.urlsafe_encode64(
          JSON.generate(
            DS_MERCHANT_AMOUNT: amount.to_s,
            DS_MERCHANT_CONSUMERLANGUAGE: language_code,
            DS_MERCHANT_CURRENCY: currency_code,
            DS_MERCHANT_IDENTIFIER: "REQUIRED",
            DS_MERCHANT_MERCHANTCODE: merchant_code,
            DS_MERCHANT_MERCHANTNAME: merchant_name,
            DS_MERCHANT_MERCHANTURL: notification_url,
            DS_MERCHANT_ORDER: order_id,
            DS_MERCHANT_PRODUCTDESCRIPTION: product_description,
            DS_MERCHANT_MERCHANTDATA: product_description,
            DS_MERCHANT_TERMINAL: terminal,
            DS_MERCHANT_TRANSACTIONTYPE: transaction_type,
            DS_MERCHANT_URLKO: url_ko,
            DS_MERCHANT_URLOK: url_ok
          )
        )
      end

      def parse_response(response)
        envelope = Hash.from_xml(response)
        envelope = envelope.dig("Envelope", "Body") if envelope.present?
        return nil unless envelope

        self.document_literal_style = envelope["notificacion"].present?
        raw_message = document_literal_style ? envelope.dig("notificacion", "datoEntrada") : envelope.dig("procesaNotificacionSIS", "XML")
        return nil unless raw_message

        message = Hash.from_xml(raw_message)
        {
          message: message["Message"],
          raw_request: raw_message.match("<Request(.*)</Request>").to_s,
          request: message.dig("Message", "Request")
        }
      rescue REXML::ParseException
        nil
      end

      def response_message
        xml = Builder::XmlMarkup.new
        response = xml.Response Ds_Version: "0.0" do
          xml.Ds_Response_Merchant(success? ? "OK" : "KO")
        end
        signature = mac256(order_key, response)

        xml = Builder::XmlMarkup.new
        xml.Message do
          xml.Response Ds_Version: "0.0" do
            xml.Ds_Response_Merchant(success? ? "OK" : "KO")
          end
          xml.Signature(signature)
        end
      end

      def envelope(message)
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.tag! "SOAP-ENV:Envelope", "xmlns:SOAP-ENV" => "http://schemas.xmlsoap.org/soap/envelope/",
                                      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                      "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
          xml.tag! "SOAP-ENV:Body" do
            if document_literal_style
              xml.notificacionResponse xmlns: "http://notificador.webservice.sis.redsys.es" do
                xml.notificacionReturn message, xmlns: "http://notificador.webservice.sis.redsys.es"
              end
            else
              xml.ns1 :procesaNotificacionSIS, "xmlns:ns1" => "InotificacionSIS", "SOAP-ENV:encodingStyle" => "http://schemas.xmlsoap.org/soap/encoding/" do
                xml.return message, "xsi:type" => "xsd:string"
              end
            end
          end
        end
      end

      def currency_code
        ActiveMerchant::Billing::RedsysGateway::CURRENCY_CODES[currency&.upcase] ||
          ActiveMerchant::Billing::RedsysGateway::CURRENCY_CODES["EUR"]
      end

      def currency_code=(value)
        self.currency = CURRENCY_CODES_BACK[value]
      end

      def language_code
        LANGUAGES[language&.downcase] || LANGUAGES[:es]
      end

      def order_id
        @order_id ||= SecureRandom.random_number(10_000).to_s + SecureRandom.base58[0..1] + customer_id.to_s(36).rjust(6, "0")
      end

      def order_id=(value)
        @order_id = value
        self.customer_id = value[6..11].to_i(36)
      end

      def url_ok
        @url_ok ||= return_url.sub("__RESULT__", "ok")
      end

      def url_ko
        @url_ko ||= return_url.sub("__RESULT__", "ko")
      end

      def valid_datetime?(response, date_limit)
        Time.parse("#{response["Fecha"]} #{response["Hora"]} #{Time.now.zone}") > date_limit
      end

      def valid_signature?(signature, response_data)
        signature == mac256(order_key, response_data)
      end

      def order_key
        encrypt(Base64.strict_decode64(secret_key), order_id)
      end

      def mac256(key, data)
        Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", key, data))
      end

      def encrypt(key, data)
        cipher = OpenSSL::Cipher.new("DES3")
        cipher.encrypt
        cipher.key = key
        cipher.padding = 0
        data_copy = data
        data_copy += "\0" until (data_copy.bytesize % 8).zero? # Pad with zeros
        cipher.update(data_copy) + cipher.final
      end
    end
  end
end
