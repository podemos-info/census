# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  def base_role?
    true
  end
end
