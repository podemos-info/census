# frozen_string_literal: true

class Visit < ApplicationRecord
  has_many :events, dependent: :restrict_with_exception

  belongs_to :admin, optional: true

  alias_attribute :user, :admin
end
