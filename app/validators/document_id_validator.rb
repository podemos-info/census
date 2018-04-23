# frozen_string_literal: true

# This validator takes care of normalizing and validating a document identifier format.
class DocumentIdValidator < ActiveModel::EachValidator
  include ActiveModel::Validations::SpanishVatValidatorsHelpers

  def initialize(args = {})
    @type_method = args[:type] || :type
    @scope_method = args[:scope] || :scope
    super
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless validate_document_id(record.send(@type_method), record.send(@scope_method), value)
  end

  def validate_document_id(type, scope, value)
    return false if value.nil?

    # Basic check for minimum length
    return false if value.length < Settings.people.document_id_minimum_length

    # This validations apply only for spanish documents.
    return true if scope != "ES"

    validate_spanish_document(type, value)
  end

  def validate_spanish_document(type, value)
    case type.to_sym
    when :dni
      value.upcase == value && validate_nif(value)
    when :nie
      value.upcase == value && validate_nie(value)
    when :passport
      value.match(/^([A-Z]\d{10})|([A-Z]{2,3}\d{6})$/).present?
    end
  end
end
