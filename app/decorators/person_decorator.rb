# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  include PersonAssociationsDecorations

  delegate_all

  decorates_association :scope
  decorates_association :address_scope
  decorates_association :document_scope
  decorates_association :issues

  sensible_fields :document_type, :document_id, :full_document_scope, :born_at, :address, :postal_code, :email, :phone

  def name
    full_name
  end

  alias to_s name

  def full_name
    [last_names, object.first_name].reject(&:blank?).join(", ")
  end

  def listable_name
    "#{[object.first_name, last_names].reject(&:blank?).join(" ")} (##{object.id})"
  end

  def last_names
    @last_names ||= begin
      ret = [last_name1, last_name2].reject(&:blank?)
      ret.join(" ")
    end
  end

  def last_name1
    @last_name1 ||= if can?(:show)
                      object.last_name1
                    else
                      convert_to_initials(object.last_name1)
                    end
  end

  def last_name2
    @last_name2 ||= if can?(:show)
                      object.last_name2
                    else
                      convert_to_initials(object.last_name2)
                    end
  end

  def full_document
    @full_document ||= sensible_data do
      "#{document_type_name}#{" - #{document_scope.name}" if object.passport_document_type? && object.document_scope} - #{object.document_id}" if object.document_id
    end
  end

  def full_document_scope
    sensible_data do
      document_scope&.full_path
    end
  end

  def full_scope
    scope&.local_path
  end

  def full_address_scope
    sensible_data do
      address_scope&.full_path
    end
  end

  def email_link
    sensible_data do
      h.link_to(object.email, "mailto:#{object.email}") if object.email
    end
  end

  def gender_name
    I18n.t("census.people.genders.#{gender}") if gender
  end

  def document_type_name
    I18n.t("census.people.document_types.#{document_type}") if document_type
  end

  def last_locations
    @last_locations ||= PersonLastLocations.for(object)
  end

  def count_locations
    @count_locations ||= PersonCountLocations.for(object)
  end

  def self.gender_options
    @gender_options ||= Person.genders.keys.map do |gender|
      [I18n.t("census.people.genders.#{gender}"), gender]
    end.freeze
  end

  def self.document_type_options
    @document_type_options ||= Person.document_types.keys.map do |document_type|
      [I18n.t("census.people.document_types.#{document_type}"), document_type]
    end.freeze
  end

  def self.country_options
    @country_options ||= ([Scope.local.decorate] + Scope.where(parent: Scope.non_local).order(name: :asc).decorate).map do |scope|
      [scope.name, scope.id]
    end.freeze
  end

  def convert_to_initials(string)
    return "" if string.strip.blank?

    "#{string.strip.first.upcase}."
  end
end
