# frozen_string_literal: true

class BicPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def destroy?
    base_role? && master?
  end
end
