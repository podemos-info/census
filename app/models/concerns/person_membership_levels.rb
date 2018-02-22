# frozen_string_literal: true

module PersonMembershipLevels
  extend ActiveSupport::Concern

  included do
    include FlagShihTzu

    has_flags 1 => :verified_by_document,
              2 => :verified_in_person,
              column: "verifications",
              check_for_column: false

    aasm :membership_levels, column: "membership_level" do
      state :follower, initial: true
      state :member

      event :to_follower do
        transitions from: [:pending, :member], to: :follower
      end

      event :to_member do
        transitions from: [:pending, :follower], to: :member, guard: :memberable?
      end
    end

    scope :verified, -> { where.not verifications: 0 }
    scope :not_verified, -> { where verifications: 0 }

    def self.membership_level_names
      @membership_level_names ||= aasm(:membership_levels).states.map(&:name).map(&:to_s)
    end

    def self.flags
      flag_mapping.values.flat_map(&:keys)
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

    def can_change_membership_level?(target)
      aasm(:membership_levels).events(permitted: true).map(&:name).include? :"to_#{target}"
    end
  end
end
