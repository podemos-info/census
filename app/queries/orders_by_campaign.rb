# frozen_string_literal: true

class OrdersByCampaign < Rectify::Query
  def self.for(campaign_code:)
    new(campaign_code: campaign_code).query
  end

  def initialize(campaign_code:)
    @campaign_code = campaign_code
  end

  def query
    Order.joins(:campaign).where(campaigns: { campaign_code: @campaign_code })
  end
end
