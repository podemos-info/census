# frozen_string_literal: true

class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :status
end
