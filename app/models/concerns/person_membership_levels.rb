# frozen_string_literal: true

module PersonMembershipLevels
  extend ActiveSupport::Concern

  included do
    include FlagShihTzu
    include AASM

    scope :verified, -> { where.not verifications: 0 }
    scope :not_verified, -> { where verifications: 0 }
    has_flags 1 => :verified_by_document,
              2 => :verified_in_person,
              column: "verifications",
              check_for_column: false

    aasm column: :membership_level do
      state :person, initial: true
      state :follower, :member

      event :to_follower do
        transitions from: [:person, :member], to: :follower
      end

      event :to_member do
        transitions from: [:person, :follower], to: :member, guard: :memberable?
      end
    end

    def self.membership_levels
      @membership_levels ||= Person.aasm.states.map(&:name).map(&:to_s)
    end

    def self.flags
      flag_mapping.values.flat_map(&:keys)
    end

    def memberable?
      verified? && born_at < 18.years.ago
    end

    def verified?
      verifications.positive?
    end

    def can_change_membership_level?(target)
      aasm.events(permitted: true).map(&:name).include? :"to_#{target}"
    end
  end
end
