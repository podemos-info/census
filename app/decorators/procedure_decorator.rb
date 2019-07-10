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

  def summary
    case object
    when ::Procedures::MembershipLevelChange
      from = I18n.t("activerecord.attributes.person.membership_level/#{object.from_membership_level}") if object.from_membership_level
      h.raw "#{from} &rarr; #{I18n.t("activerecord.attributes.person.membership_level/#{object.to_membership_level}")}"
    else
      ""
    end
  end

  def link(text = nil)
    return text unless can? :show

    if object.processable?
      edit_link(text)
    else
      view_link(text)
    end
  end

  def view_link(text = nil)
    h.link_to text || I18n.t("active_admin.view"), h.procedure_path(object), class: "member_link"
  end

  def edit_link(text = nil)
    h.link_to text || I18n.t("census.procedures.process"), h.procedure_path(object), class: "member_link"
  end

  def comment
    @comment ||= if object.comment.match(/^[a-z_]+$/)
                   I18n.t("census.procedures.comments.#{object.comment}", default: object.comment)
                 else
                   object.comment
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
    object.attachments.order(id: :asc).decorate(context: context)
  end

  def before_person
    return person unless processed?

    @before_person ||= person.paper_trail.version_at(processed_at - 0.01.seconds, dup: true)&.decorate(context: context)
  end

  def after_person
    @after_person ||= if processed?
                        person.paper_trail.version_at(processed_at + 0.01.seconds, dup: true)&.decorate(context: context)
                      else
                        object.deep_dup.tap(&:process_accept).person&.decorate(context: context)
                      end
  end

  def person_changeset
    @person_changeset ||= begin
      changed_attributes = before_person.attributes.keys.zip(before_person.attributes.values.zip(after_person.attributes.values))
                                        .reject { |_attribute, values| values.first == values.last }
                                        .map(&:first)
      classed_changeset(changed_attributes, "")
    end
  end
end
