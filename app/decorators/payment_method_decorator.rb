# frozen_string_literal: true

class PaymentMethodDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def route_key
    "payment_methods"
  end

  def singular_route_key
    "payment_method"
  end
end
