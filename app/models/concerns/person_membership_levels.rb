# frozen_string_literal: true

module PersonMembershipLevels
  extend ActiveSupport::Concern

  included do
    include FlagShihTzu
    include AASM

    has_flags 1 => :verified_by_document,
              2 => :verified_in_person,
              column: "verifications",
              check_for_column: false

    aasm column: :membership_level do
      state :pending, initial: true
      state :rejected
      state :follower, :member

      event :prepare do
        transitions from: [:pending, :rejected], to: :pending
      end

      event :register do
        transitions from: :pending, to: :follower
      end

      event :reject do
        transitions from: :pending, to: :rejected
      end

      event :undo do
        transitions from: [:follower, :rejected], to: :pending
      end

      event :to_follower do
        transitions from: [:pending, :member], to: :follower
      end

      event :to_member do
        transitions from: [:pending, :follower], to: :member, guard: :memberable?
      end
    end

    scope :verified, -> { where.not verifications: 0 }
    scope :not_verified, -> { where verifications: 0 }
    scope :enabled, -> { where membership_level: [:follower, :member] }

    def self.membership_levels
      @membership_levels ||= Person.aasm.states.map(&:name).map(&:to_s)
    end

    def self.flags
      flag_mapping.values.flat_map(&:keys)
    end

    def enabled?
      follower? || member?
    end

    def memberable?
      verified? && adult?
    end

    def adult?
      born_at < 18.years.ago
    end

    def verified?
      verifications.positive?
    end

    def can_register?
      aasm.events(permitted: true).map(&:name).include? :register
    end

    def can_change_membership_level?(target)
      aasm.events(permitted: true).map(&:name).include? :"to_#{target}"
    end
  end
end
