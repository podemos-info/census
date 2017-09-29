# frozen_string_literal: true

class OrderDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person
  decorates_association :payment_method

  def name
    object.description
  end

  def full_amount
    Money.new(object.amount, object.currency).format
  end

  def person_full_name
    person.decorate.full_name
  end

  def payment_method_name
    payment_method.id ? payment_method.name : I18n.t("census.orders.create_credit_card_external")
  end

  def payment_method_id
    payment_method ? payment_method.id : nil
  end
end
