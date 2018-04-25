# frozen_string_literal: true

class IssuePolicy < ApplicationPolicy
  def index?
    !real_issue? || show?
  end

  def show?
    user.role_includes?(record)
  end

  def create?
    user.data_help_role?
  end

  def update?
    show? && record&.open?
  end

  def assign_me?
    show?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      AdminIssues.for(@user)
    end
  end

  private

  def real_issue?
    !record.is_a?(Class) && record.role.present?
  end
end
