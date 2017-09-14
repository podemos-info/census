# frozen_string_literal: true

class OrderDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def to_s
    object.description
  end

  def full_amount
    Money.new(object.amount, object.currency).format
  end
end
