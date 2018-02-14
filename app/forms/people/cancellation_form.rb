# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class CancellationForm < Form
    include ::HasPerson

    mimic :cancellation

    attribute :reason, String
  end
end
