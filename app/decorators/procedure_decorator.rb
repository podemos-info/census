# frozen_string_literal: true

class ProcedureDecorator < ApplicationDecorator
  delegate_all

  attr_accessor :event
  decorates_association :dependent_procedures
  decorates_association :issues
  decorates_association :person
  decorates_association :processed_by

  def name
    "#{type_name} ##{id}"
  end

  alias to_s name
  alias listable_name name

  def actions_options(admin:, allow_add_issue: false)
    @actions_options ||= begin
      actions = object.permitted_events(admin)
      actions.append(:issue) if allow_add_issue
      actions.map do |event|
        [I18n.t("census.procedures.actions.#{event}"), event]
      end
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

  def link(text = nil)
    return text unless can? :show

    if object.processed?
      view_link(text)
    else
      edit_link(text)
    end
  end

  def link_with_name
    link(name)
  end

  def view_link(text = nil)
    h.link_to text || I18n.t("active_admin.view"), h.procedure_path(object), class: "member_link"
  end

  def edit_link(text = nil)
    h.link_to text || I18n.t("census.procedures.process"), h.edit_procedure_path(object), class: "member_link"
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
    object.attachments.order(id: :asc).decorate(context: context)
  end

  def processed_person
    return nil unless processed?
    @processed_person ||= person.paper_trail.version_at(processed_at)&.decorate(context: context)
  end

  def processed_person_classed_changeset
    return {} unless processed_person
    @processed_person_classed_changeset ||= begin
      changed_attributes = person.attributes.keys.zip(person.attributes.values.zip(processed_person.attributes.values))
                                 .reject { |_attribute, values| values.first == values.last }
                                 .map(&:first)
      classed_changeset(changed_attributes, "version_change")
    end
  end
end
