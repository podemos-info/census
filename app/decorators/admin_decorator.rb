# frozen_string_literal: true

class AdminDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def name
    person.full_name
  end

  def role_name
    I18n.t("census.admins.roles.#{object.role}")
  end

  def self.role_options
    @roles ||= Admin.roles.keys.map do |role|
      [I18n.t("census.admins.roles.#{role}"), role]
    end.freeze
  end

  def current_sign_in_ip
    format_ip object.current_sign_in_ip
  end

  def last_sign_in_ip
    format_ip object.last_sign_in_ip
  end

  def last_visits
    @last_visits ||= AdminLastVisits.for(object).decorate
  end

  def count_visits
    @count_visits ||= object.visits.count
  end
end
