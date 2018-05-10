# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class RegistrationForm < PersonDataForm
    include ::CanHavePerson

    mimic :person

    attribute :origin_qualified_id, String

    validates :origin_qualified_id, presence: true
    validate :validate_not_registered

    def complete_required?
      true
    end

    def person_data
      {
        first_name: first_name,
        last_name1: last_name1,
        last_name2: last_name2,
        document_type: document_type,
        document_id: document_id,
        document_scope_id: document_scope&.id,
        born_at: born_at,
        gender: gender,
        address: address,
        address_scope_id: address_scope&.id,
        postal_code: postal_code,
        scope_id: scope&.id,
        email: email,
        phone: phone,
        external_ids: external_ids
      }
    end

    private

    def validate_not_registered
      errors.add :person, :cant_register_again if person.present? && !person.may_accept?
    end

    def external_ids
      parts = origin_qualified_id.split("@")
      { parts[1] => parts[0].to_i }
    end
  end
end
