# frozen_string_literal: true

# This validator takes care of validating a postal code.
class PostalCodeValidator < ActiveModel::EachValidator
  include ActiveModel::Validations::SpanishVatValidatorsHelpers

  def initialize(args = {})
    @scope_method = args[:scope] || :scope
    super
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless validate_postal_code(record.send(@scope_method), value)
  end

  def validate_postal_code(scope, value)
    validate_spanish_postal_code(scope, value)
  end

  def validate_spanish_postal_code(scope, value)
    return true unless scope

    province = scope.part_of_scopes.map { |s| s.mappings["INE-PROV"] } .compact.first
    return true unless province

    /^#{province}\d{3}$/.match? value
  end
end
