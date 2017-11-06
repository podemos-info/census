# frozen_string_literal: true

class IssueDecorator < ApplicationDecorator
  delegate_all

  decorates_association :assigned_to

  def name
    issue_type_name
  end

  def issue_type_name
    I18n.t("census.issues.types.#{object.issue_type}")
  end

  def role_name
    I18n.t("census.admins.roles.#{object.role}")
  end

  def level_name
    I18n.t("census.issues.levels.#{object.level}")
  end

  def objects_links
    object.issue_objects.map do |issue_object|
      object = issue_object.object.decorate
      h.link_to object.name, h.url_for(object)
    end.to_sentence.html_safe
  end
end
