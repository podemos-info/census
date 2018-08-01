# frozen_string_literal: true

class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :status, :verified?

  def status
    return "inactive" unless object.active?
    return "incomplete" unless object.complete?
    "active"
  end
end
