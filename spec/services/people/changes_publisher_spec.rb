# frozen_string_literal: true

require "rails_helper"

describe People::ChangesPublisher do
  describe "#full_status_changed!" do
    subject(:method) { described_class.full_status_changed!(person) }

    let(:person) { create(:person) }

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            age: person.age,
            document_type: person.document_type,
            person: person.qualified_id,
            state: person.state,
            membership_level: person.membership_level,
            verification: person.verification,
            scope_code: person.scope&.code
          }
        ]
      end
    end
  end
end
