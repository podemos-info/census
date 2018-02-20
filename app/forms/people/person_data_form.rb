# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataForm < Form
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

    normalize :first_name, :last_name1, :last_name2, with: [:whitespace, :blank]
    normalize :address, :postal_code, with: :whitespace

    validates :scope, presence: true, if: :scope_code
    validates :address_scope, presence: true, if: :address_scope_code
    validates :document_scope, presence: true

    validates :document_id, document_id: { type: :document_type, scope: :document_scope_code }
    validate :valid_document_scope?

    def document_id=(value)
      super value && document_type ? Normalizr.normalize(value, :"document_#{document_type}") : value
    end

    def document_type=(value)
      super value
      self.document_id = document_id if document_id.present?
    end

    def document_scope
      @document_scope ||= Scope.find_by_code(document_scope_code)
    end

    def scope
      @scope ||= Scope.find_by_code(scope_code)
    end

    def address_scope
      @address_scope ||= Scope.find_by_code(address_scope_code)
    end

    def valid_document_scope?
      if document_type != "passport" && !Scope.local_code?(document_scope_code)
        errors.add :document_scope_code, :should_be_local
      end
    end
  end
end
