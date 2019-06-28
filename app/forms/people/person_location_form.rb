# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonLocationForm < Form
    include ::HasPerson

    mimic :person_location

    attribute :ip, String
    attribute :user_agent, String
    attribute :time, Time

    validates :ip, :user_agent, :time, presence: true

    def time=(value)
      super(
        if value.is_a?(Integer) || value.is_a?(Float)
          Time.zone.at(value)
        else
          value
        end
      )
    end
  end
end
