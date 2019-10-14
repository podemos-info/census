# frozen_string_literal: true

require "rails_helper"

describe Procedures::Cancellation, :db do
  subject(:procedure) { create(:cancellation, :ready_to_process, person: person) }

  let(:person) { create(:person, :member) }

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.to be_auto_processable }

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "changes the person state" do
      expect { subject } .to change(person, :state).from("enabled").to("cancelled")
    end

    it "destroys the person" do
      expect { subject } .to change(person, :discarded_at).from(nil)
    end

    it "sends an email to the person" do
      subject
      expect(ActionMailer::Parameterized::DeliveryJob).to have_been_enqueued.on_queue("mailers")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { "census.people.full_status_changed" }
      let(:publish_notification_args) do
        {
          person: person.qualified_id,
          external_ids: person.external_ids,
          state: "cancelled",
          verification: person.verification
        }
      end
    end

    context "when person wasn't a member" do
      let(:person) { create(:person) }

      it "sends an email to the person" do
        subject
        expect(ActionMailer::Parameterized::DeliveryJob).not_to have_been_enqueued.on_queue("mailers")
      end
    end
  end

  context "when rejected" do
    it "doesn't change the person state" do
      expect { procedure.reject! } .not_to change(person, :state).from("enabled")
    end

    it "doesn't destroy the person" do
      expect { procedure.reject! } .not_to change(person, :discarded_at)
    end

    it "doesn't sends an email to the person" do
      subject
      expect(ActionMailer::Parameterized::DeliveryJob).not_to have_been_enqueued.on_queue("mailers")
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  with_versioning do
    context "when has accepted the procedure" do
      subject(:undo) { procedure.undo! }

      before { procedure.accept! }

      it "recovers the person" do
        expect { subject } .to change(person, :discarded_at).to(nil)
      end

      it "recovers the person state" do
        expect { subject } .to change(person, :state).from("cancelled").to("enabled")
      end
    end
  end
end
