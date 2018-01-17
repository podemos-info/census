# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonForm < Form
    mimic :person

    attribute :id, Integer

    attribute :first_name, String
    attribute :last_name1, String
    attribute :last_name2, String
    attribute :document_type, String
    attribute :document_id, String
    attribute :document_scope_code, String
    attribute :born_at, Date
    attribute :gender, String
    attribute :address, String
    attribute :address_scope_code, String
    attribute :postal_code, String
    attribute :email, String
    attribute :scope_code, String
    attribute :phone, String
    attribute :extra, Hash

    normalize :first_name, :last_name1, :last_name2, with: [:whitespace, :blank]
    validates :first_name, :last_name1, presence: true

    validates :document_type, inclusion: { in: Person.document_types.keys }, presence: true
    validates :document_id, document_id: { type: :document_type, scope: :document_scope_code }, presence: true
    validates :document_scope_code, presence: true

    validates :born_at, presence: true

    validates :gender, inclusion: { in: Person.genders.keys }, presence: true

    normalize :address, :postal_code, with: :whitespace
    validates :address, :address_scope_code, :postal_code, presence: true

    validates :email, :scope_code, presence: true

    def document_id=(value)
      super value && document_type ? Normalizr.normalize(value, :"document_#{document_type}") : value
    end

    def document_type=(value)
      super value
      self.document_id = document_id if document_id.present?
    end

    def document_scope
      Scope.find_by_code(document_scope_code)
    end

    def scope
      Scope.find_by_code(scope_code)
    end

    def address_scope
      Scope.find_by_code(address_scope_code)
    end
  end
end
