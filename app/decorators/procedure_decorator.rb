# frozen_string_literal: true

class ProcedureDecorator < ApplicationDecorator
  delegate_all

  attr_accessor :event
  decorates_association :person
  decorates_association :processed_by
  decorates_association :dependent_procedures
  decorates_association :attachments

  def to_s
    "#{type_name} - #{person.full_name}"
  end

  def type_name
    I18n.t("activerecord.models.procedures.#{ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(object.model_name.to_s))}.one")
  end

  def available_events_options
    @available_events_options ||= object.aasm.events(permitted: true).map do |event|
      [I18n.t("census.procedure.events.#{event.name}"), event.name]
    end
  end

  def information
    case object
    when ::Procedures::MembershipLevelChange
      h.raw "#{I18n.t("activerecord.attributes.person.level/#{object.from_level}")} &rarr; #{I18n.t("activerecord.attributes.person.level/#{object.to_level}")}"
    else
      "-"
    end
  end

  def view_link text = nil
    if procedure.processable?
      h.link_to text || I18n.t("census.procedure.process"), h.edit_procedure_path(object), class: "member_link"
    else
      h.link_to text || I18n.t("active_admin.view"), h.procedure_path(object), class: "member_link"
    end
  end
end
