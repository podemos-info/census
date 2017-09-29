# frozen_string_literal: true

class VisitDecorator < ApplicationDecorator
  delegate_all

  decorates_association :admin

  def name
    "#{admin&.name || ip} - #{h.pretty_format(object.started_at)}"
  end

  def location
    [object.country, object.region, object.city].compact.join ", "
  end

  def coordinates
    [object.latitude, object.longitude].join ", "
  end

  def screen_resolution
    [object.screen_height, object.screen_width].join "x"
  end
end
