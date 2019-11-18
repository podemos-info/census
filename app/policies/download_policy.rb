# frozen_string_literal: true

class DownloadPolicy < ApplicationPolicy
  def base_role?
    true
  end

  def show?
    for_me? || user.data_role?
  end

  def create?
    false
  end

  def update?
    false
  end

  def download?
    show?
  end

  def destroy?
    show? && !record.discarded? && master?
  end

  def recover?
    show? && record.discarded? && master?
  end

  def for_me?
    download_instance? && user.person == record.person
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if @user.data_role?
        @scope
      else
        @scope.where(person: @user.person)
      end
    end
  end

  private

  def download_instance?
    !record.is_a?(Class) && record.person.present?
  end
end
