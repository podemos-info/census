# frozen_string_literal: true

class AdminDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def name
    person.full_name
  end

  def current_sign_in_ip
    format_ip object.current_sign_in_ip
  end

  def last_sign_in_ip
    format_ip object.last_sign_in_ip
  end

  def last_versions
    @last_versions ||= object.versions.reorder(created_at: :desc).limit(3).decorate
  end

  def count_versions
    @count_versions ||= object.versions.where(event: "update").count + 1
  end

  def last_visits
    @last_visits ||= object.visits.order(started_at: :desc).limit(3).decorate
  end

  def count_visits
    @count_visits ||= object.visits.count
  end
end
