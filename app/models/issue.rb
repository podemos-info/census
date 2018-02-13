# frozen_string_literal: true

class Issue < ApplicationRecord
  include HasRole

  self.inheritance_column = :issue_type
  enum level: [:very_low, :low, :medium, :high, :very_high], _suffix: true

  has_many :issue_objects

  has_many :downloads, -> { distinct }, through: :issue_objects, source: :object, source_type: "Download"
  has_many :orders, -> { distinct }, through: :issue_objects, source: :object, source_type: "Order"
  has_many :payment_methods, -> { distinct }, through: :issue_objects, source: :object, source_type: "PaymentMethod"
  has_many :people, -> { distinct }, through: :issue_objects, source: :object, source_type: "Person"
  has_many :procedures, -> { distinct }, through: :issue_objects, source: :object, source_type: "Procedure"

  has_many :issue_unreads
  has_many :unread_admins, through: :issue_unreads, foreign_key: "admin_id", class_name: "Admin"

  belongs_to :assigned_to, class_name: "Person", optional: true

  attr_accessor :issuable

  def absent?
    new_record? && !detected?
  end

  def fixed?
    !detected?
  end

  class << self
    def for(issuable)
      issue = find_for(issuable) || build_for(issuable)
      issue.issuable = issuable
      issue
    end

    def i18n_messages_scope; end
  end
end
