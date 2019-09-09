# frozen_string_literal: true

require "rails_helper"

describe People::ChangesPublisher do
  describe "#confirm_email_change!" do
    subject(:method) { described_class.confirm_email_change!(person, email) }

    let(:person) { create(:person) }
    let(:email) { Faker::Internet.unique.email }

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { "census.people.confirm_email_change" }
      let(:publish_notification_args) do
        {
          person: person.qualified_id,
          external_ids: person.external_ids,
          email: email
        }
      end
    end
  end

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
