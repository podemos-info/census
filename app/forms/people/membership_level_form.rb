# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class MembershipLevelForm < Form
    mimic :membership_level_change

    attribute :person_id, Integer
    attribute :membership_level, String

    validates :person_id, :person, presence: true
    validates :membership_level, presence: true, inclusion: { in: Person.membership_levels }

    def person
      @person ||= Person.find(person_id)
    end

    def change?
      person.membership_level != membership_level
    end
  end
end
