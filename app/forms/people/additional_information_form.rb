# frozen_string_literal: true

# The form object that handles the additional information for a person
module People
  class AdditionalInformationForm < Form
    include ::HasPerson

    attribute :key, String
    attribute :json_value, String

    validate :validate_key
    validate :validate_value

    def value
      return @value if defined?(@value)

      @value = JSON.parse(json_value)
    end

    private

    def validate_key
      return if /^[a-z][_a-z0-9]+$/.match?(key)

      errors.add :key, :invalid
    end

    def validate_value
      value
    rescue JSON::ParserError => _e
      @value = nil
      errors.add :value, :invalid_format
    end
  end
end
