# frozen_string_literal: true

# The person model.
class Person < ApplicationRecord
  include FlagShihTzu
  include AASM

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

  aasm column: :level do
    state :person, initial: true
    state :follower, :young_member, :member

    event :to_follower do
      transitions from: [:person, :young_member, :member], to: :follower, guard: :verified?
    end

    event :to_member do
      transitions from: [:person, :follower, :young_member], to: :member, guard: :memberable?
      transitions from: [:person, :follower], to: :young_member, guard: :young_memberable?
    end
  end

  def memberable?
    verified? && born_at < 18.years.ago
  end

  def young_memberable?
    verified? && born_at > 18.years.ago
  end

  def verified?
    verifications.positive?
  end

  def can_change_level?(target)
    aasm.events(permitted: true).map(&:name).include? :"to_#{target}"
  end

  def scope_code=(value)
    self.scope = Scope.find_by_code(value)
  end

  def address_scope_code=(value)
    self.address_scope = Scope.find_by_code(value)
  end

  def self.flags
    flag_mapping.values.map(&:keys).flatten
  end
end
