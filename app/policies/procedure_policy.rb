# frozen_string_literal: true

class ProcedurePolicy < ApplicationPolicy
  def base_role?
    user.lopd_help_role? || super
  end

  def scope
    Pundit.policy_scope!(user, Procedure)
  end

  def create?
    false
  end

  def undo?
    base_role?
  end

  def view_attachment?
    base_role?
  end
end
