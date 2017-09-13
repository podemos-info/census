# frozen_string_literal: true

# The form object that handles the data for an order
module Orders
  class OrderForm < Form
    mimic :order

    attribute :person_id, Integer
    attribute :description, String
    attribute :amount, Integer

    validates :person_id, :description, :amount, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }

    def currency
      Settings.payments.currency
    end

    def person
      Person.find(person_id)
    end
  end
end
