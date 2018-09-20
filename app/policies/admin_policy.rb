# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.data_role? || super
  end

  def show?
    return true if user == record

    user.data_role? || super
  end

  def create?
    false
  end
end
