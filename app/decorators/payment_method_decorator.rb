# frozen_string_literal: true

class PaymentMethodDecorator < Draper::Decorator
  delegate_all

  decorates_association :person

  def type_name
    super("payment_method")
  end
end
