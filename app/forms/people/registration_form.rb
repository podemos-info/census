# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class RegistrationForm < PersonDataForm
    include ::CanHavePerson

    mimic :person

    validates :first_name, :last_name1, presence: true

    validates :document_type, inclusion: { in: Person.document_types.keys }, presence: true
    validates :document_id, document_id: { type: :document_type, scope: :document_scope_code }, presence: true
    validates :document_scope_code, presence: true

    validates :born_at, presence: true

    validates :gender, inclusion: { in: Person.genders.keys }, presence: true

    validates :address, :address_scope_code, :postal_code, presence: true

    validates :email, :scope_code, presence: true

    validates :scope, :address_scope, :document_scope, presence: true

    validate :validate_not_registered

    private

    def validate_not_registered
      errors.add :person, :cant_register_again if person.present? && !person.may_accept?
    end
  end
end
