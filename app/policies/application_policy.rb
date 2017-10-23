# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    base_role?
  end

  def show?
    base_role? && scope.where(id: record.id).exists?
  end

  def new?
    create?
  end

  def create?
    base_role?
  end

  def edit?
    update?
  end

  def update?
    base_role?
  end

  def destroy?
    false
  end

  def base_role?
    user.system_role?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope
    end
  end
end
