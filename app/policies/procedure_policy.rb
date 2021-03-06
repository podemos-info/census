# frozen_string_literal: true

class ProcedurePolicy < ApplicationPolicy
  def base_role?
    if person&.cancelled?
      user.data_role?
    else
      user.data_help_role? || super
    end
  end

  def create?
    false
  end

  def update?
    !person&.discarded? && base_role? && master?
  end

  alias process? update?
  alias undo? update?

  def view_attachment?
    base_role?
  end

  def person
    record&.try(:person)
  end
end
