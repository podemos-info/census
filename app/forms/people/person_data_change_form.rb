# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataChangeForm < PersonDataForm
    mimic :person

    include ::HasPerson
  end
end
