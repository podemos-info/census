# frozen_string_literal: true

# The form object that handles the data for an order with an existing payment method
module Orders
  class ExistingPaymentMethodOrderForm < OrderForm
    attribute :payment_method_id, Integer
    validates :payment_method_id, presence: true
    validate :validate_active_payment_method

    def payment_method_id=(value)
      super(value)
      self.person_id = payment_method&.person&.id if value
    end

    def payment_method
      @payment_method ||= PaymentMethod.find_by(id: payment_method_id)
    end

    private

    def validate_active_payment_method
      errors.add(:payment_method_id, :inactive_payment_method) unless payment_method&.active?
    end
  end
end
