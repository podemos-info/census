# frozen_string_literal: true

module PersonLevels
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
    has_flags 1 => :has_issues,
              check_for_column: false

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

    def self.levels
      @levels ||= Person.aasm.states.map(&:name).map(&:to_s)
    end

    def self.flags
      flag_mapping.values.flat_map(&:keys)
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
  end
end
