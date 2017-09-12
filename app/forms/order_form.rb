# frozen_string_literal: true

# The form object that handles the data for an order
class OrderForm < Form
  mimic :order

  attribute :person_id, Integer
  attribute :description, String
  attribute :amount, Integer
  attribute :payment_method_info, PaymentMethodForm

  validates :person_id, :description, :amount, :payment_method_info, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def currency
    Settings.payments.currency
  end

  def person
    Person.find(person_id)
  end

  def payment_method
    @payment_method ||= if @payment_method_info.existing?
                          PaymentMethod.find_by(id: @payment_method_info.id)
                        else
                          @payment_method_info.build(person)
                        end
  end
end
