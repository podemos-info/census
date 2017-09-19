# frozen_string_literal: true

class PaymentMethodDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person
end
