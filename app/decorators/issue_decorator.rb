# frozen_string_literal: true

class IssueDecorator < ApplicationDecorator
  delegate_all

  decorates_association :assigned_to

  def name
    issue_type_name
  end

  alias to_s name
  alias listable_name name

  def issue_type_name
    I18n.t("census.issues.types.#{object.issue_type.underscore}")
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
      obj = issue_object.object.decorate
      h.link_to obj.listable_name, h.url_for(obj)
    end.to_sentence.html_safe
  end

  def link
    h.link_to name, h.url_for(self)
  end
end
