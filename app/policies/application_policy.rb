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
    base_role?
  end

  def new?
    create?
  end

  def create?
    base_role? && master?
  end

  def edit?
    update?
  end

  def update?
    base_role? && master?
  end

  def destroy?
    false
  end

  def base_role?
    user.system_role?
  end

  def master?
    !Settings.system.slave_mode
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
