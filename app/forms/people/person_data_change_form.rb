# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataChangeForm < PersonDataForm
    include ::HasPerson

    mimic :person

    validates :document_type, inclusion: { in: Person.document_types.keys }, allow_blank: true
    validates :gender, inclusion: { in: Person.genders.keys }, allow_blank: true

    def document_type
      @document_type || person.document_type
    end

    def document_scope_code
      @document_scope_code || person.document_scope&.code
    end

    def document_id
      @document_id || person.document_id
    end

    def has_changes?
      [:first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address, :postal_code, :email, :phone].any? do |attribute|
        attributes[attribute].present? && attributes[attribute] != person.send(attribute)
      end ||
        [:document_scope, :address_scope, :scope].any? do |attribute|
          code_attribute = :"#{attribute}_code"
          attributes[code_attribute].present? && attributes[code_attribute] != person.send(attribute)&.code
        end
    end
  end
end
