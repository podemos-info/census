# frozen_string_literal: true

class PersonDecorator < Draper::Decorator
  delegate_all

  decorates_association :scope
  decorates_association :address_scope

  def to_s
    full_name
  end

  def full_name
    "#{last_names}, #{object.first_name}"
  end

  def last_names
    [object.last_name1, object.last_name2].reject(&:blank?).join(" ")
  end

  def full_document
    "#{I18n.t("census.people.document_types.#{object.document_type}")} - #{object.document_id}"
  end

  def gender_name
    I18n.t("census.people.genders.#{gender}")
  end

  def document_type_name
    I18n.t("census.people.document_types.#{document_type}")
  end

  def flags
    @flags ||= Person.flags.select { |flag| person.send(flag) }
  end

  def self.gender_options
    @gender_options ||= Person::GENDERS.map do |gender|
      [I18n.t("census.people.genders.#{gender}"), gender]
    end.freeze
  end

  def self.document_type_options
    @document_types ||= Person::DOCUMENT_TYPES.map do |document_type|
      [I18n.t("census.people.document_types.#{document_type}"), document_type]
    end.freeze
  end

  def independent_procedures
    @independent_procedures ||= object.procedures.independent.order(id: :asc).decorate
  end
end
