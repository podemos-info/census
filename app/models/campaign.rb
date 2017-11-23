# frozen_string_literal: true

class Campaign < ApplicationRecord
  belongs_to :payee, optional: true
  has_many :orders
end
