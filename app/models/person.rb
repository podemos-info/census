# frozen_string_literal: true

class Person < ApplicationRecord
  include Discard::Model
  include AASM
  include PersonStates
  include PersonVerifications
  include PersonMembershipLevels
  include Issuable
  include ExternalSystems

  has_paper_trail class_name: "Version"

  belongs_to :document_scope,
             class_name: "Scope",
             optional: true
  belongs_to :address_scope,
             class_name: "Scope",
             optional: true
  belongs_to :scope,
             optional: true

  has_many :issues_assigned, foreign_key: "assigned_to_id", class_name: "Issue"
  has_many :versions, as: :item
  has_many :procedures
  has_many :orders
  has_many :payment_methods
  has_many :downloads

  enum document_type: [:dni, :nie, :passport], _suffix: true
  enum gender: [:female, :male, :other, :undisclosed], _suffix: true
end
