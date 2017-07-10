# frozen_string_literal: true

class ScopeType < ApplicationRecord
  has_many :scopes

  validates :name, :plural, presence: true
end
