# frozen_string_literal: true

# The form object that handles the data for an order
module Orders
  class OrderForm < Form
    mimic :order

    attribute :person_id, Integer
    attribute :description, String
    attribute :amount, Integer
    attribute :campaign_code, String

    validates :person_id, :description, :amount, :campaign_code, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }

    def currency
      @currency ||= Settings.payments.currency
    end

    def person
      @person ||= Person.find(person_id)
    end

    def campaign
      @campaign ||= Campaign.find_or_initialize(campaign_code: campaign_code)
    end

    def self.from_params(params)
      return super unless self == OrderForm
      class_name = "orders/#{params[:payment_method_type]}_order_form".classify
      class_name.constantize.from_params(params) if Object.const_defined?(class_name)
    end
  end
end
