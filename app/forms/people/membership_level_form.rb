# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class MembershipLevelForm < Form
    include ::HasPerson

    mimic :membership_level_change

    attribute :membership_level, String

    validates :membership_level, presence: true, inclusion: { in: Person.membership_levels }

    def change?
      person&.membership_level != membership_level
    end
  end
end
