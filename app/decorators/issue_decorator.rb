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

  def description
    if object.issue_type.to_sym == :processed_response_code
      I18n.t("census.payment_methods.issues_messages.#{object.description}")
    else
      object.description
    end
  end

  def objects_links
    object.issue_objects.map do |issue_object|
      obj = issue_object.object.decorate
      h.link_to obj.name, h.url_for(obj)
    end.to_sentence.html_safe
  end
end
