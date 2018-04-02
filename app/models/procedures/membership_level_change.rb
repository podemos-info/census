# frozen_string_literal: true

module Procedures
  class MembershipLevelChange < Procedure
    store_accessor :information, :from_membership_level, :to_membership_level

    validates :to_membership_level, presence: true

    def acceptable?
      person.enabled? && person.can_change_membership_level?(to_membership_level)
    end

    def process_accept
      self.from_membership_level = person.membership_level
      person.send("to_#{to_membership_level}")
    end

    def undo_accept
      person.membership_level = from_membership_level
    end

    def persist_accept_changes!
      person.save!
    end
  end
end
