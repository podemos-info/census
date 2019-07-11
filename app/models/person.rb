# frozen_string_literal: true

class Person < ApplicationRecord
  include AASM
  include Discard::Model

  include ExternalSystems
  include Issuable
  include PersonMembershipLevels
  include PersonPhoneVerifications
  include PersonStates
  include PersonVerifications

  has_paper_trail versions: { class_name: "Version" }

  belongs_to :document_scope, class_name: "Scope", optional: true
  belongs_to :address_scope, class_name: "Scope", optional: true
  belongs_to :scope, optional: true

  has_many :assigned_issues, dependent: :restrict_with_exception, foreign_key: "assigned_to_id", class_name: "Issue", inverse_of: :assigned_to
  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item
  has_many :procedures, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
  has_many :payment_methods, dependent: :restrict_with_exception
  has_many :downloads, dependent: :restrict_with_exception
  has_many :person_locations, dependent: :restrict_with_exception

  enum document_type: [:dni, :nie, :passport], _suffix: true
  enum gender: [:female, :male, :other, :undisclosed], _suffix: true

  include FastFilter
end
