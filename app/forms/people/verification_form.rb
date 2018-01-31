# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class VerificationForm < Form
    mimic :verification_document

    attribute :person_id, Integer
    attribute :files, Array

    validates :person_id, :person, presence: true
    validate :files_presence

    def person
      @person ||= Person.find_by(id: person_id)
    end

    def files_presence
      validates_length_of :files, minimum: (person&.document_type == "passport" ? 1 : 2)
    end

    def files=(value)
      super(value.map { |file| parse_uploaded_file file })
    end
  end
end
