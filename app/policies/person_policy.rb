# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def base_role?
    true
  end

  def show?
    user.data_role? || !record&.discarded?
  end

  def create?
    false
  end

  def update?
    user.data_help_role? && !record.discarded?
  end

  def request_verification?
    update?
  end
end
