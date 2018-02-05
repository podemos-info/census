# frozen_string_literal: true

module Issues
  # A command to create, update or fix issues for processed orders
  class CheckProcessedOrderIssues < CheckIssues
    # Public: Initializes the command.
    #
    # order - The order to check
    # admin - The admin user triggered the check
    def initialize(order:, admin:)
      @order = order
      @payment_method = order.payment_method
      @admin = admin
    end

    private

    attr_reader :order, :payment_method

    def update_affected_objects
      issue.orders << order
      issue.payment_methods = [payment_method]
    end

    def has_issue?
      payment_method.user_visible? && payment_method.response_code.present? && response_code_info[:role].present?
    end

    def issue
      @issue ||= ::PaymentMethodProcessingIssues.for(payment_method).merge(::IssuesNonFixed.for).first || Issue.new(
        issue_type: :processed_response_code,
        description: issue_message,
        role: issue_role,
        level: :medium,
        assigned_to: issue_assigned_to,
        information: {
          response_code: order.response_code
        },
        fixed_at: nil
      )
    end

    def issue_assigned_to
      @issue_assigned_to ||= response_code_info[:role] == "user" ? @order.person : nil
    end

    def issue_role
      @issue_role ||= response_code_info[:role] == "user" ? nil : Admin.roles[response_code_info[:role]]
    end

    def issue_message
      @issue_message ||= response_code_info[:message]
    end

    def response_code_info
      @response_code_info ||= Payments::Processor.payment_processor_response_code_info response_code: order.response_code,
                                                                                       payment_processor: payment_method.payment_processor
    end
  end
end
