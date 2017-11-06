# frozen_string_literal: true

class PaymentMethodProcessingIssues < Rectify::Query
  def self.for(payment_method)
    new(payment_method).query
  end

  def initialize(payment_method)
    @payment_method = payment_method
  end

  def query
    @payment_method.issues.where(issue_type: :processed_response_code)
  end
end
