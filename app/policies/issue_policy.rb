# frozen_string_literal: true

class IssuePolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    return true unless real_issue?

    user.role_includes?(record)
  end

  def create?
    user.data_help_role? && master?
  end

  def update?
    return false unless real_issue?

    show? && record.open? && master?
  end

  def assign_me?
    show? && master?
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
