# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataChangeForm < PersonDataForm
    mimic :person

    include ::HasPerson

    validates :document_type, inclusion: { in: Person.document_types.keys }, allow_blank: true
    validates :gender, inclusion: { in: Person.genders.keys }, allow_blank: true

    def document_type
      @document_type || person.document_type
    end

    def document_scope_code
      @document_scope_code || person.document_scope.code
    end

    def document_id
      @document_id || person.document_id
    end
  end
end
