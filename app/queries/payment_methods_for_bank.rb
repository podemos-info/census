# frozen_string_literal: true

class PaymentMethodsForBank < Rectify::Query
  def self.for(iban:)
    new(pattern: IbanBic.like_pattern(iban, :country, :bank)).query
  end

  def self.for_parts(country:, **parts)
    new(pattern: IbanBic.like_pattern_from_parts(country: country, **parts)).query
  end

  def initialize(pattern:)
    @pattern = pattern
  end

  def query
    PaymentMethods::DirectDebit.where("information ->> 'iban' LIKE ?", @pattern)
  end
end
