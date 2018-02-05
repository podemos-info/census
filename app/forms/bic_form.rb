# frozen_string_literal: true

# The form object that handles the data for a bic
class BicForm < Form
  mimic :bic

  attribute :country, String
  attribute :bank_code, String
  attribute :bic, String

  normalize :country, :bic, with: [:clean, :upcase]

  validates :bic, bic: { country: :country }, presence: true
  validates :country, :bank_code, presence: true, unless: :persisted?
end
