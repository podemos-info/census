# frozen_string_literal: true

class Payee < ApplicationRecord
  has_many :campaigns, dependent: :restrict_with_exception
  belongs_to :scope
end
