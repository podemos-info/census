# frozen_string_literal: true

class OrderDecorator < ApplicationDecorator
  delegate_all

  decorates_association :campaign
  decorates_association :orders_batch
  decorates_association :payment_method
  decorates_association :person

  def name
    object.description
  end

  alias to_s name
  alias listable_name name

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
