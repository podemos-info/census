# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  class << self
    def basic_attributes(*attributes)
      attributes.each do |attribute|
        attribute attribute, if: -> { include?(attribute.to_s) }
      end
    end

    def sensible_attributes(*attributes)
      attributes.each do |attribute|
        attribute attribute, if: -> { !discarded? && include?(attribute.to_s) }
      end
    end
  end

  basic_attributes :person_id, :external_ids, :scope_code, :state,
                   :membership_level, :verification, :phone_verification

  sensible_attributes :first_name, :last_name1, :last_name2,
                      :document_type, :document_id, :document_scope_code,
                      :born_at, :gender, :email, :phone,
                      :address, :address_scope_code, :postal_code,
                      :additional_information, :membership_allowed?, :created_at

  has_many :scopes, if: -> { !discarded? && include?("scopes") }

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
    @discarded ||= if object.paper_trail.live?
                     object.discarded?
                   else
                     Person.find(object.id).discarded?
                   end
  end

  def include?(attribute)
    (includes.empty? || includes.member?(attribute)) && !excludes.member?(attribute)
  end

  private

  def excludes
    @excludes ||= instance_options[:excludes].presence || %w(scopes)
  end

  def includes
    @includes ||= instance_options[:includes] || []
  end
end
