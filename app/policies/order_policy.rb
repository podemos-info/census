# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def charge?
    user.finances_role? && master?
  end
end
