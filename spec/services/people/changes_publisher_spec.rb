# frozen_string_literal: true

require "rails_helper"

describe People::ChangesPublisher do
  describe "#full_status_changed!" do
    subject(:method) { described_class.full_status_changed!(person) }
    let(:person) { create(:person) }

    let(:publish_notification) do
      {
        routing_key: "census.people.full_status_changed",
        parameters: { person: person.qualified_id }
      }
    end
    include_context "hutch notifications"
  end
end
