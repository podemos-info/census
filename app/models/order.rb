# frozen_string_literal: true

class Order < ApplicationRecord
  include OrderStates
  include Issuable

  acts_as_paranoid
  has_paper_trail class_name: "Version"

  has_many :versions, as: :item
  belongs_to :person
  belongs_to :payment_method, autosave: true
  belongs_to :orders_batch, optional: true
  belongs_to :processed_by, class_name: "Admin", optional: true
  belongs_to :campaign

  store_accessor :information, :raw_response

  validate :same_person_than_payment_method

  def possible_issues
    [Issues::Payments::ProcessingIssue] if response_code.present?
  end

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

  def processable?(args = {})
    payment_method.processable?(args) &&
      (pending? || reprocessable?)
  end

  def reprocessable?
    processed? && payment_method.reprocessable? && processed_at > Settings.payments.allow_reprocess_hours.hours.ago
  end

  def external_authorization?
    payment_method.external_authorization?
  end

  def payment_processor
    payment_method.payment_processor
  end
end
