# frozen_string_literal: true

class OrdersBatchPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def review_orders?
    user.finances_role?
  end

  def charge?
    user.finances_role?
  end
end
