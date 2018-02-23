# frozen_string_literal: true

class PaymentMethodDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  delegate :name, to: :object
  alias to_s name
  alias listable_name name

  def flags
    @flags ||= PaymentMethod.flags.select { |flag| object.send(flag) }
  end

  def person_full_name
    person.decorate.full_name
  end

  def last_orders
    @last_orders ||= PaymentMethodLastOrders.for(object).decorate
  end

  def route_key
    "payment_methods"
  end

  def singular_route_key
    "payment_method"
  end
end
