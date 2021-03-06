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

    def self.membership_level_names
      @membership_level_names ||= aasm(:membership_level).states.map(&:name).map(&:to_s)
    end

    def memberable?
      kept? && verified? && membership_allowed?
    end

    def adult?
      born_at < 18.years.ago
    end

    alias_method :membership_allowed?, :adult?

    def may_change_membership_level?(target)
      aasm(:membership_level).may_fire_event? :"to_#{target}"
    end
  end
end
