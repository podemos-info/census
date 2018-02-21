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
      reason: reason
    )
  end

  let(:reason) { "Because yes!" }

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to change the person membership level" do
      expect { subject } .to change { Procedures::Cancellation.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::Cancellation.count }
    end
  end

  describe "when a procedure already exists for the person" do
    let!(:procedure) { create(:cancellation, person: person) }

    it "does not create a new procedure" do
      expect { subject } .not_to change { Procedures::Cancellation.count }
    end

    describe "the updated procedure" do
      before { command }
      let(:reason) { "changed" }

      it "updates the reason column in the existing procedure" do
        expect(procedure.reload.reason).to eq("changed")
      end
    end
  end
end
