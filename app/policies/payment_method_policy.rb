# frozen_string_literal: true

class PaymentMethodPolicy < ApplicationPolicy
  def base_role?
    user.finances_role? || super
  end

  def dismiss_issues?
    base_role?
  end
end
