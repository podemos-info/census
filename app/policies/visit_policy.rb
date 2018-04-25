# frozen_string_literal: true

class VisitPolicy < ApplicationPolicy
  def index?
    user.data_role? || super
  end

  def show?
    user.data_role? || super
  end

  def create?
    false
  end

  def update?
    false
  end
end
