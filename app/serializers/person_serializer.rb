# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address,
             :postal_code, :email, :phone, :membership_level, :scope_code, :address_scope_code, :document_scope_code,
             :state, :verification

  attributes Person.external_ids_attributes

  def scope_code
    object.scope&.code
  end

  def address_scope_code
    object.address_scope&.code
  end

  def document_scope_code
    object.document_scope&.code
  end
end
