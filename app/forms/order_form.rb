# frozen_string_literal: true

# The form object that handles the data for an order
class OrderForm < Form
  mimic :order

  attribute :person_id, Integer
  attribute :description, String
  attribute :amount, Integer
  attribute :payment_method_form, PaymentMethodForm

  validates :person_id, :description, :amount, :payment_method_form, presence: true
  validates :amount, numericality: { greater_than_or_equal: 0 }

  def currency
    Settings.payments.currency
  end

  def person
    Person.find(person_id)
  end

  def payment_method
    @payment_method ||= if @payment_method_form.existing?
                          PaymentMethod.find_by(id: @payment_method_form.id)
                        else
                          @payment_method_form.build(person)
                        end
  end
end
