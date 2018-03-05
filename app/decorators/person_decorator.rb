# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  delegate_all

  decorates_association :scope
  decorates_association :address_scope
  decorates_association :document_scope

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
    [object.last_name1, object.last_name2].reject(&:blank?).join(" ")
  end

  def full_document
    "#{document_type_name} - #{object.document_id}" if object.document_id
  end

  def full_scope
    scope&.show_path
  end

  def full_address_scope
    address_scope&.show_path
  end

  def gender_name
    I18n.t("census.people.genders.#{gender}") if gender
  end

  def document_type_name
    I18n.t("census.people.document_types.#{document_type}") if document_type
  end

  def flags
    @flags ||= Person.flags.select { |flag| person.send(flag) }
  end

  def full_name_link
    h.link_to full_name, object
  end

  def self.gender_options
    @gender_options ||= Person.genders.keys.map do |gender|
      [I18n.t("census.people.genders.#{gender}"), gender]
    end.freeze
  end

  def self.document_type_options
    @document_types ||= Person.document_types.keys.map do |document_type|
      [I18n.t("census.people.document_types.#{document_type}"), document_type]
    end.freeze
  end

  def independent_procedures
    @independent_procedures ||= PersonIndependentProcedures.for(object).decorate
  end

  def last_procedures
    @last_procedures ||= PersonLastIndependentProcedures.for(object).decorate
  end

  def count_procedures
    @count_procedures ||= independent_procedures.count
  end

  def last_orders
    @last_orders ||= PersonLastOrders.for(object).decorate
  end

  def count_orders
    @count_orders ||= object.orders.count
  end

  def count_payment_methods
    @count_payment_methods ||= object.payment_methods.count
  end

  def last_downloads
    @last_downloads ||= PersonLastActiveDownloads.for(object).decorate
  end
end
