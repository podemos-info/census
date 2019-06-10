# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class CancellationForm < Form
    include ::HasPerson

    mimic "Procedures::Cancellation"

    attribute :channel, String
    attribute :reason, String

    validates :channel, presence: true
  end
end
