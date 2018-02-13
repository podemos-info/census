# frozen_string_literal: true

module Issues
  module Payments
    class ProcessingIssue < Issue
      store_accessor :information, :response_code

      def detected?
        payment_method.user_visible? && payment_method.response_code.present? && response_code_info[:role].present?
      end

      def fill
        self.description = issue_message
        self.role = issue_role
        self.assigned_to = issue_assigned_to

        orders << order
        self.payment_methods = [payment_method]
      end

      alias order issuable

      private

      def payment_method
        order.payment_method
      end

      def response_code_info
        @response_code_info ||= ::Payments::Processor.payment_processor_response_code_info response_code: order.response_code,
                                                                                           payment_processor: payment_method.payment_processor
      end

      def issue_assigned_to
        @issue_assigned_to ||= response_code_info[:role] == "user" ? order.person : nil
      end

      def issue_role
        @issue_role ||= response_code_info[:role] == "user" ? nil : Admin.roles[response_code_info[:role]]
      end

      def issue_message
        @issue_message ||= response_code_info[:message]
      end

      class << self
        def find_for(order)
          ::PaymentMethodProcessingIssues.for(order.payment_method).merge(::IssuesNonFixed.for).first
        end

        def build_for(order)
          ProcessingIssue.new(
            level: :medium,
            response_code: order.response_code
          )
        end

        def i18n_messages_scope
          "census.payment_methods.issues_messages"
        end
      end
    end
  end
end
