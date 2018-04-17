# frozen_string_literal: true

class ScopeType < ApplicationRecord
  has_many :scopes, dependent: :restrict_with_exception

  validates :name, :plural, presence: true
end
