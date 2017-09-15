# frozen_string_literal: true

# The form object that handles the data for an order with an existing payment method
module Orders
  class ExistingPaymentMethodOrderForm < OrderForm
    attribute :payment_method_id, Integer
    validates :payment_method_id, presence: true

    def payment_method_id=(value)
      super(value)
      self.person_id = payment_method.person.id if value
    end

    def payment_method
      @payment_method ||= PaymentMethod.find(payment_method_id)
    end
  end
end
