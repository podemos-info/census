# frozen_string_literal: true

# The person model.
class Person < ApplicationRecord
  include PersonLevels
  include FlagShihTzu

  store_accessor :extra, :participa_id

  belongs_to :document_scope,
             class_name: "Scope",
             optional: true
  belongs_to :address_scope,
             class_name: "Scope",
             optional: true

  has_many :procedures

  belongs_to :scope,
             optional: true

  has_flags 1 => :has_issues,
            check_for_column: false
  has_flags 1 => :verified_by_document,
            2 => :verified_in_person,
            column: "verifications",
            check_for_column: false

  acts_as_paranoid
  has_paper_trail

  scope :verified, -> { where.not verifications: 0 }
  scope :not_verified, -> { where verifications: 0 }

  DOCUMENT_TYPES = %w(dni nie passport).freeze
  GENDERS = %w(female male other undisclosed).freeze
end
