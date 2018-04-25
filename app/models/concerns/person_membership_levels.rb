# frozen_string_literal: true

module PersonMembershipLevels
  extend ActiveSupport::Concern

  included do
    enum membership_level: [:follower, :member]

    aasm :membership_level, column: "membership_level", enum: true, create_scopes: false do
      state :follower, initial: true
      state :member

      event :to_follower do
        transitions from: :member, to: :follower, guard: :kept?
      end

      event :to_member do
        transitions from: :follower, to: :member, guard: :memberable?
      end
    end

    scope :follower, -> { enabled.where(membership_level: :follower) }
    scope :member, -> { enabled.where(membership_level: :member) }

    def self.membership_level_names
      @membership_level_names ||= aasm(:membership_level).states.map(&:name).map(&:to_s)
    end

    def memberable?
      kept? && verified? && adult?
    end

    def adult?
      born_at < 18.years.ago
    end

    def may_change_membership_level?(target)
      aasm(:membership_level).may_fire_event? :"to_#{target}"
    end
  end
end
