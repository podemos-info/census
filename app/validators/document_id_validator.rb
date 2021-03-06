# frozen_string_literal: true

# This validator takes care of validating a document identifier format.
class DocumentIdValidator < ActiveModel::EachValidator
  include ActiveModel::Validations::SpanishVatValidatorsHelpers

  SPANISH_PASSPORT_REGEX = /^([A-Z]\d{10})|([A-Z]{2,3}\d{6})$/.freeze

  def initialize(args = {})
    @type_method = args[:type] || :type
    @scope_method = args[:scope] || :scope
    super
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless validate_document_id(record.send(@type_method), record.send(@scope_method), value)
  end

  def validate_document_id(type, scope, value)
    # Basic check for minimum length
    return false if value.length < Settings.people.document_id_minimum_length

    # This validations apply only for spanish documents.
    return true if scope != "ES"

    validate_spanish_document(type, value)
  end

  def validate_spanish_document(type, value)
    return false if type.blank?

    case type.to_sym
    when :dni
      value.upcase == value && validate_nif(value)
    when :nie
      value.upcase == value && validate_nie(value)
    when :passport
      SPANISH_PASSPORT_REGEX.match? value
    end
  end
end
