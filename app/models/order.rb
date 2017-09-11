# frozen_string_literal: true

# The order model.
class Order < ApplicationRecord
  include OrderStates

  belongs_to :person
  belongs_to :payment_method, autosave: true
  belongs_to :orders_batch, optional: true
  belongs_to :processed_by, class_name: "Person", optional: true

  store_accessor :information, :raw_response

  def date
    created_at&.to_date || Date.today
  end

  def processable?
    pending? && payment_method.processable?(self)
  end

  def external_authorization?
    payment_method.external_authorization?
  end

  def payment_processor
    payment_method.payment_processor
  end
end
