# frozen_string_literal: true

# The person model.
class Person < ApplicationRecord
  include PersonLevels
  include FlagShihTzu

  acts_as_paranoid
  has_paper_trail

  store_accessor :extra, :participa_id

  belongs_to :document_scope,
             class_name: "Scope",
             optional: true
  belongs_to :address_scope,
             class_name: "Scope",
             optional: true

  has_many :procedures
  has_many :orders
  has_many :payment_methods

  belongs_to :scope,
             optional: true

  has_flags 1 => :has_issues,
            check_for_column: false
  has_flags 1 => :verified_by_document,
            2 => :verified_in_person,
            column: "verifications",
            check_for_column: false

  scope :verified, -> { where.not verifications: 0 }
  scope :not_verified, -> { where verifications: 0 }

  enum document_type: [:dni, :nie, :passport], _suffix: true
  enum gender: [:female, :male, :other, :undisclosed], _suffix: true
end
