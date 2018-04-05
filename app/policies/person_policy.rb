# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def base_role?
    user.lopd_role? || !record&.discarded?
  end

  def show?
    base_role?
  end

  def create?
    false
  end

  def update?
    user.lopd_help_role? && !record.discarded?
  end

  def request_verification?
    update?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @user.lopd_role? ? Person.all : Person.kept
    end
  end
end
