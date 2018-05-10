# frozen_string_literal: true

require "rails_helper"

describe People::ChangesPublisher do
  describe "#full_status_changed!" do
    subject(:method) { described_class.full_status_changed!(person) }
    let(:person) { create(:person) }

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { ["census.people.full_status_changed", { person: person.qualified_id }] }
    end
  end
end