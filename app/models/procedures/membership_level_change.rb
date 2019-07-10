# frozen_string_literal: true

module Procedures
  class MembershipLevelChange < Procedure
    store_accessor :information, :from_membership_level, :to_membership_level

    validates :to_membership_level, presence: true

    def acceptable?
      person.enabled? && person.may_change_membership_level?(to_membership_level)
    end

    def process_accept
      self.from_membership_level = person.membership_level
      person.send("to_#{to_membership_level}")
    end

    def undo_accept
      person.membership_level = from_membership_level
    end

    def persist_changes!
      return unless person.has_changes_to_save?

      person.save!
      ::People::ChangesPublisher.full_status_changed!(person)
      send_affiliation_change_email
    end

    private

    def send_affiliation_change_email
      if person.member?
        PeopleMailer.affiliated(person).deliver_later(wait: undo_minutes)
      else
        PeopleMailer.unaffiliated(person).deliver_later(wait: undo_minutes)
      end
    end
  end
end
