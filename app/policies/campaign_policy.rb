# frozen_string_literal: true

class CampaignPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def destroy?
    base_role?
  end
end
