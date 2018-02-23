# frozen_string_literal: true

class VisitDecorator < ApplicationDecorator
  delegate_all

  decorates_association :admin

  def name
    "#{admin&.name || ip} - #{h.pretty_format(object.started_at)}"
  end

  alias to_s name
  alias listable_name name

  def location
    [object.country, object.region, object.city].compact.join ", "
  end

  def coordinates
    [object.latitude, object.longitude].join ", "
  end

  def last_events
    @last_events ||= VisitLastEvents.for(object).decorate
  end

  def count_events
    @count_events ||= object.events.count
  end
end
