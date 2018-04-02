# frozen_string_literal: true

class IssueDecorator < ApplicationDecorator
  delegate_all

  decorates_association :assigned_to

  def name
    issue_type_name
  end

  alias to_s name
  alias listable_name name

  def issue_type
    @issue_type ||= object.issue_type.underscore.sub("issues/", "")
  end

  def issue_type_name
    "#{I18n.t("census.issues.types.#{issue_type}.name")} ##{object.id}"
  end

  def issue_type_tip
    I18n.t("census.issues.types.#{issue_type}.tip")
  end

  def role_name
    I18n.t("census.admins.roles.#{object.role}")
  end

  def level_name
    I18n.t("census.issues.levels.#{object.level}")
  end

  def description
    return I18n.t("#{object.class.i18n_messages_scope}.#{object.description}") if object.class.i18n_messages_scope

    object.description
  end

  def objects_links
    object.issue_objects.map do |issue_object|
      obj = issue_object.object.decorate(context: context)
      h.link_to obj.listable_name, h.url_for(obj)
    end.to_sentence.html_safe
  end

  def people_by_creation_date
    @people_by_creation_date ||= object.people.decorate(context: context).sort_by(&:created_at)
  end

  def classed_relevant_attributes
    @classed_relevant_attributes ||= object.class.stored_attributes[:information].zip(["relevant"].cycle).to_h
  end

  def fix_attributes
    @fix_attributes ||= object.class.try(:fix_attributes) || object.class.stored_attributes[:fix_information]
  end

  def link(text = nil)
    if object.closed?
      view_link(text)
    else
      edit_link(text)
    end
  end

  def link_with_name
    link(name)
  end

  def view_link(text = nil)
    h.link_to text || I18n.t("active_admin.view"), h.issue_path(object), class: "member_link"
  end

  def edit_link(text = nil)
    h.link_to text || I18n.t("census.issues.close.action"), h.edit_issue_path(object), class: "member_link"
  end

  def status
    if object.closed?
      object.close_result
    else
      "open"
    end
  end

  def status_name
    I18n.t("census.issues.status.#{status}")
  end
end
