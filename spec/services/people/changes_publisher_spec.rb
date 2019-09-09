# frozen_string_literal: true

require "rails_helper"

describe People::ChangesPublisher do
  describe "#full_status_changed!" do
    subject(:method) { described_class.full_status_changed!(person) }

    let(:person) { create(:person) }

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { "census.people.full_status_changed" }
      let(:publish_notification_args) do
        {
          person: person.qualified_id,
          external_ids: person.external_ids,
          state: person.state,
          verification: person.verification,
          membership_level: person.membership_level,
          scope_code: person.scope&.code,
          document_type: person.document_type,
          age: person.age
        }
      end
    end
  end
end
