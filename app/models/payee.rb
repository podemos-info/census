# frozen_string_literal: true

class Payee < ApplicationRecord
  has_many :campaigns
  belongs_to :scope
end
