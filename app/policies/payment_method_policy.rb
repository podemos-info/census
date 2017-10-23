# frozen_string_literal: true

class PaymentMethodPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def scope
    Pundit.policy_scope!(user, PaymentMethod)
  end

  def dismiss_issues?
    base_role?
  end
end
