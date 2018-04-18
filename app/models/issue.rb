# frozen_string_literal: true

class Issue < ApplicationRecord
  include HasRole

  self.inheritance_column = :issue_type
  enum level: [:very_low, :low, :medium, :high, :very_high], _suffix: true
  enum close_result: [:fixed, :gone, :not_fixed]

  has_many :issue_objects, dependent: :destroy

  has_many :downloads, -> { distinct }, through: :issue_objects, source: :object, source_type: "Download"
  has_many :orders, -> { distinct }, through: :issue_objects, source: :object, source_type: "Order"
  has_many :payment_methods, -> { distinct }, through: :issue_objects, source: :object, source_type: "PaymentMethod"
  has_many :people, -> { distinct }, through: :issue_objects, source: :object, source_type: "Person"
  has_many :procedures, -> { distinct }, through: :issue_objects, source: :object, source_type: "Procedure"

  has_many :issue_unreads, dependent: :destroy
  has_many :unread_admins, through: :issue_unreads, foreign_key: "admin_id", class_name: "Admin"

  belongs_to :assigned_to, class_name: "Person", inverse_of: :assigned_issues, optional: true

  attr_accessor :fixing, :issuable

  def absent?
    new_record? && !detected?
  end

  def closed?
    closed_at.present?
  end

  def open?
    !closed?
  end

  def fix!
    self.fixing = true
    return false if closed? || invalid?

    do_the_fix

    self.close_result ||= :fixed
    self.closed_at = Time.zone.now
    save!
    true
  end

  def gone!
    return if closed?

    self.close_result = :gone
    self.closed_at = Time.zone.now
    save!
  end

  def fixed_for?(_issuable)
    closed?
  end

  def post_close(_admin); end

  class << self
    def for(issuable, find: true)
      issue = (find && find_for(issuable)) || build_for(issuable)
      issue.issuable = issuable
      issue
    end

    def i18n_messages_scope; end
  end
end
