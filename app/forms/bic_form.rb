# frozen_string_literal: true

# The form object that handles the data for a bic
class BicForm < Form
  mimic :bic

  attribute :country, String
  attribute :bank_code, String
  attribute :bic, String

  validates :country, :bank_code, :bic, presence: true
end
