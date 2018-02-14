# frozen_string_literal: true

class CampaignDecorator < ApplicationDecorator
  delegate_all

  def name
    object.description || "[#{object.campaign_code}]"
  end

  alias to_s name
end
