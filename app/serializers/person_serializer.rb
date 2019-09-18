# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :person_id, :membership_level, :scope_code, :state, :verification, :phone_verification, :external_ids
  attribute :first_name, unless: :discarded?
  attribute :last_name1, unless: :discarded?
  attribute :last_name2, unless: :discarded?
  attribute :document_type, unless: :discarded?
  attribute :document_id, unless: :discarded?
  attribute :document_scope_code, unless: :discarded?
  attribute :born_at, unless: :discarded?
  attribute :gender, unless: :discarded?
  attribute :address, unless: :discarded?
  attribute :postal_code, unless: :discarded?
  attribute :address_scope_code, unless: :discarded?
  attribute :email, unless: :discarded?
  attribute :phone, unless: :discarded?
  attribute :additional_information, unless: :discarded?
  attribute :membership_allowed?, unless: :discarded?
  attribute :created_at, unless: :discarded?

  has_many :scopes, if: :with_scopes_info?

  def scopes
    Scope.includes(:scope_type).where(id: (
      object.scope.part_of +
      object.address_scope.part_of +
      object.document_scope.part_of
    ).uniq)
  end

  def person_id
    object.id
  end

  def scope_code
    object.scope&.code
  end

  def address_scope_code
    object.address_scope&.code
  end

  def document_scope_code
    object.document_scope&.code
  end

  def discarded?
    if object.paper_trail.live?
      object.discarded?
    else
      Person.find(object.id).discarded?
    end
  end

  def with_scopes_info?
    !discarded? && instance_options[:with_scopes]
  end
end
