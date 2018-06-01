# frozen_string_literal: true

class FilledValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    required = options.fetch(:required, true)
    required = record.send(required) if required.is_a? Symbol

    record.errors.add(attribute, :blank) if value.blank? && (required || !value.nil?)
  end
end
