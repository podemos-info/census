# frozen_string_literal: true

module Payments
  class Processor
    def format_order_id(order)
      order.date.strftime("%y%m%d") + (order.id % 1_000_000).to_s.rjust(6, "0")
    end

    def name
      self.class.to_s.demodulize.underscore
    end

    class << self
      def for(name)
        "payments/processors/#{name}".camelize.constantize.new
      end

      def payment_processor_response_code_info(payment_processor:, response_code:)
        payment_processor_response_code.dig(payment_processor, response_code) || { message: :unknown, target: :system }
      end

      private

      def payment_processor_response_code
        @payment_processor_response_code ||= begin
          ret = {}
          Settings.payments.processors.each do |payment_processor, processor_info|
            ret[payment_processor] = {}
            processor_info.response_codes&.each do |message, info|
              info.codes&.each do |response_code|
                ret[payment_processor][response_code] = { message: message, **info }
              end
            end
          end
          ret.freeze
        end
      end
    end
  end
end
