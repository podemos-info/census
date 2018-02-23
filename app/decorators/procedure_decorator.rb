# frozen_string_literal: true

class ProcedureDecorator < ApplicationDecorator
  delegate_all

  attr_accessor :event
  decorates_association :person
  decorates_association :processed_by
  decorates_association :dependent_procedures

  def name
    "#{type_name} ##{id}"
  end

  def permitted_events_options(processed_by)
    @permitted_events_options ||= object.permitted_events(processed_by).map do |event|
      [I18n.t("census.procedures.events.#{event}"), event]
    end
  end

  def information
    case object
    when ::Procedures::MembershipLevelChange
      h.raw "#{I18n.t("activerecord.attributes.person.membership_level/#{object.from_membership_level}")}
             &rarr; #{I18n.t("activerecord.attributes.person.membership_level/#{object.to_membership_level}")}"
    else
      ""
    end
  end

  def view_link(text = nil)
    if procedure.processable?
      h.link_to text || I18n.t("census.procedures.process"), h.edit_procedure_path(object), class: "member_link"
    else
      h.link_to text || I18n.t("active_admin.view"), h.procedure_path(object), class: "member_link"
    end
  end

  def route_key
    "procedures"
  end

  def singular_route_key
    "procedure"
  end

  def procedure_type
    object.class.name.demodulize.underscore
  end

  def self.procedures_options
    @procedures_options ||= Procedure.descendants.map { |procedure| [procedure.model_name.human, procedure.model_name.to_s] }
  end

  def attachments
    object.attachments.order(id: :asc).decorate
  end

  def processed_person
    return nil unless processed?
    @processed_person ||= person.paper_trail.version_at(processed_at).decorate
  end

  def processed_person_classed_changeset
    return {} unless processed_person
    @processed_person_classed_changeset ||= begin
      changed_attributes = person.attributes.keys.zip(person.attributes.values.zip(processed_person.attributes.values))
                                 .reject { |_attribute, values| values.first == values.last }
                                 .map(&:first)
      classed_changeset(changed_attributes, "version_change new_value")
    end
  end
end
