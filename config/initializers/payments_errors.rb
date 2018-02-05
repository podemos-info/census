# frozen_string_literal: true

module Census
  module Payments
    class UnrecoverableError < StandardError; end

    def self.logger
      @logger ||= Logger.new("log/payments.errors.log")
    end

    def self.handle_order_unrecoverable_error(order:, error:, action:)
      if order.payment_method
        payment_method_info = <<-LOG
          #{order.payment_method.as_json}
          Errors: #{order.payment_method.errors.as_json}
          Changes: #{order.payment_method.changes.as_json}
        LOG
      end

      logger.error <<-LOG
        An exception occurred when #{action}.

        - Here is the order:
          #{order.as_json}
          Errors: #{order.errors.as_json}
          Changes: #{order.changes.as_json}

        - Here is the payment method:
          #{payment_method_info || "NIL"}

        - Here is the error info:
          #{error.message} #{error.backtrace.join("\n")}" }
      LOG
    end
  end
end
