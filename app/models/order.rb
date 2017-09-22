# frozen_string_literal: true

# The order model.
class Order < ApplicationRecord
  include OrderStates

  belongs_to :person
  belongs_to :payment_method, autosave: true
  belongs_to :orders_batch, optional: true
  belongs_to :processed_by, class_name: "Admin", optional: true

  store_accessor :information, :raw_response

  validate :same_person_than_payment_method

  def payment_method=(value)
    super value
    self.person = value.person if value&.person
  end

  def same_person_than_payment_method
    errors.add(:payment_method_id, :different_person_than_payment_method) if person != payment_method&.person
  end

  def date
    created_at&.to_date || Date.today
  end

  def processable?(in_batch = false)
    pending? && payment_method.processable?(in_batch)
  end

  def external_authorization?
    payment_method.external_authorization?
  end

  def payment_processor
    payment_method.payment_processor
  end
end
