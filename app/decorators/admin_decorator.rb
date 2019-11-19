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

  def with_icon(modifier: nil)
    h.raw "<span class='admin_icon #{modifier}'>#{h.link_to(self)}</span>"
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

  def count_running_jobs
    @count_running_jobs ||= object.jobs.running.count
  end

  def count_active_downloads
    @count_active_downloads ||= PersonLastActiveDownloads.for(object.person).count
  end
end
