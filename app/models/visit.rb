# frozen_string_literal: true

class Visit < ApplicationRecord
  has_many :events

  belongs_to :admin, optional: true

  alias_attribute :user, :admin
end
