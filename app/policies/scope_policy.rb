# frozen_string_literal: true

class ScopePolicy < ApplicationPolicy
  def browse?
    true
  end
end
