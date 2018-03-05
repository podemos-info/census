# frozen_string_literal: true

class IssuePolicy < ApplicationPolicy
  def index?
    !real_issue? || show?
  end

  def scope
    Pundit.policy_scope!(user, Issue)
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def update?
    false
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
