# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class VerificationForm < Form
    include ::HasPerson

    mimic :verification_document

    attribute :files, Array

    validate :files_presence

    def files_presence
      validates_length_of :files, minimum: (person&.document_type == "passport" ? 1 : 2)
    end

    def files=(value)
      super(value.map { |file| parse_uploaded_file file })
    end
  end
end
