# frozen_string_literal: true

class AdminDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def name
    username
  end

  alias to_s name
  alias listable_name name

  def role_name
    I18n.t("census.admins.roles.#{object.role}")
  end

  def self.role_options
    @role_options ||= Admin.roles.keys.map do |role|
      [I18n.t("census.admins.roles.#{role}"), role]
    end.freeze
  end

  def last_visits
    @last_visits ||= AdminLastVisits.for(object).decorate(context: context)
  end

  def count_visits
    @count_visits ||= object.visits.count
  end

  def count_unread_issues
    @count_unread_issues ||= object.issue_unreads.count
  end

  def has_unread_issues?
    count_unread_issues.positive?
  end
end
