# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.lopd_role? || super
  end

  def show?
    return true if user == record
    user.lopd_role? || super
  end

  def create?
    false
  end
end
