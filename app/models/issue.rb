# frozen_string_literal: true

class Issue < ApplicationRecord
  include HasRole

  enum level: [:very_low, :low, :medium, :high, :very_high], _suffix: true

  has_many :issue_objects

  has_many :downloads, through: :issue_objects, source: :object, source_type: "Download"
  has_many :orders, through: :issue_objects, source: :object, source_type: "Order"
  has_many :payment_methods, through: :issue_objects, source: :object, source_type: "PaymentMethod"
  has_many :people, through: :issue_objects, source: :object, source_type: "Person"
  has_many :procedures, through: :issue_objects, source: :object, source_type: "Procedure"

  has_many :issue_unreads
  has_many :unread_admins, through: :issue_unreads, foreign_key: "admin_id", class_name: "Admin"

  belongs_to :assigned_to, class_name: "Person", optional: true
end
