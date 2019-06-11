# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class DocumentVerificationForm < Form
    include ::HasPerson

    mimic "Procedures::DocumentVerification"

    attribute :files, Array

    validate :validate_files_presence

    def files=(value)
      super(value.map { |file| parse_uploaded_file file })
    end

    private

    def validate_files_presence
      validates_length_of :files, minimum: (person&.document_type == "passport" ? 1 : 2)
    end
  end
end
