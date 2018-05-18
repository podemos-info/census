# frozen_string_literal: true

require "rails_helper"

describe People::CreateCancellation do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::CancellationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      channel: channel,
      reason: reason
    )
  end

  let(:channel) { "email" }
  let(:reason) { "Because yes!" }

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to cancel the person account" do
      expect { subject } .to change { Procedures::Cancellation.count } .by(1)
    end

    describe "the created procedure" do
      before { command }
      subject(:created_procedure) { Procedures::Cancellation.last }

      it "saves the reason" do
        expect(created_procedure.reload.reason).to eq("Because yes!")
      end

      it "saves the channel" do
        expect(created_procedure.reload.channel).to eq("email")
      end
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::Cancellation.count }
    end
  end

  context "when a procedure already exists for the person" do
    let!(:procedure) { create(:cancellation, person: person) }
    let(:reason) { "changed" }

    it "does not create a new procedure" do
      expect { subject } .not_to change { Procedures::Cancellation.count }
    end

    it "updates the updated_at column in the existing procedure" do
      expect { subject } .to change { procedure.reload.reason } .to("changed")
    end
  end
end
