# frozen_string_literal: true

# The form object that handles the data for a payment method
class PaymentMethodForm < Form
  mimic :payment_method

  attribute :type, Symbol
  attribute :id, Integer
  attribute :iban, String
  attribute :return_url, String
  attribute :authorization_token, String
  attribute :expiration_year, String
  attribute :expiration_month, String

  validates :type, presence: true, inclusion: { in: [:existing, :direct_debit, :credit_card_authorize, :credit_card_authorized] }

  validates :id, presence: true, if: :existing?

  validates :iban, presence: true, if: :direct_debit?
  validates_with SEPA::IBANValidator, field_name: :iban, if: :direct_debit?

  validates :return_url, presence: true, if: :credit_card_authorize?

  validates :authorization_token, :expiration_year, :expiration_month, presence: true, if: :credit_card_authorized?

  def existing?
    payment_method == :existing
  end

  def direct_debit?
    payment_method == :direct_debit
  end

  def credit_card_authorize?
    payment_method == :credit_card_authorize
  end

  def credit_card_authorized?
    payment_method == :credit_card_authorized
  end

  def build(person)
    if direct_debit?
      PaymentMethods::DirectDebit.new(
        person: person,
        iban: payment_method.iban,
        processor: Settings.payments.processors.direct_debit
      )
    elsif credit_card_authorize?
      PaymentMethods::CreditCard.new(
        person: person,
        return_url: payment_method.return_url,
        processor: Settings.payments.processors.credit_card
      )
    elsif credit_card_authorized?
      PaymentMethods::CreditCard.new(
        person: person,
        authorization_token: payment_method.authorization_token,
        expiration_year: payment_method.expiration_year,
        expiration_month: payment_method.expiration_month,
        processor: Settings.payments.processors.credit_card,
        verified: true
      )
    end
  end
end
