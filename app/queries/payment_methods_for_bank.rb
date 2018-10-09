# frozen_string_literal: true

class PaymentMethodsForBank < Rectify::Query
  def self.for_iban(iban)
    parts = IbanBic.parse(iban)
    self.for(country: parts.fetch(:country, nil), bank_code: parts.fetch(:bank, nil))
  end

  def self.for(country:, bank_code:)
    new(country: country, bank_code: bank_code).query
  end

  def initialize(country:, bank_code:)
    @country = country
    @bank_code = bank_code
  end

  def query
    PaymentMethods::DirectDebit.where("information ->> 'country' = ?", @country).where("information ->> 'bank_code' = ?", @bank_code)
  end
end
