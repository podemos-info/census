# frozen_string_literal: true

module Procedures
  class MembershipLevelChange < Procedure
    store_accessor :information, :from_level, :to_level

    validates :from_level, :to_level, presence: true

    def acceptable?
      person.can_change_level? to_level
    end

    def process_accept
      person.send("to_#{to_level}")
    end

    def undo_accept
      person.level = from_level
    end

    def persist_accept_changes!
      person.save!
    end
  end
end
