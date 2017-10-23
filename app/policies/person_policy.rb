# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def base_role?
    true
  end
end
