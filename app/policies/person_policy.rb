# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def base_role?
    user.lopd_role? || !record&.cancelled?
  end

  def show?
    base_role?
  end

  def update?
    !record.discarded?
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
