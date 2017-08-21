# frozen_string_literal: true

module Procedures
  class MembershipLevelChange < Procedure
    store_accessor :information, :from_level, :to_level

    validates :from_level, :to_level, presence: true

    def check_acceptable
      person.can_change_level? to_level
    end

    def if_accepted
      person.level = to_level
      ret = yield
      person.level = from_level
      ret
    end

    def after_accepted
      person.send("to_#{to_level}!")
    end

    def undo
      person.level = from_level
      person.save!
    end
  end
end
