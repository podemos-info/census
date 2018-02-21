# frozen_string_literal: true

require "rails_helper"

describe People::CreateDocumentVerification do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::DocumentVerificationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      files: files
    )
  end

  let(:files) { [build(:attachment).file, build(:attachment).file] }

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to verify the person document" do
      expect { subject } .to change { Procedures::DocumentVerification.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::DocumentVerification.count }
    end
  end

  describe "when a procedure already exists for the person" do
    let!(:procedure) { create(:document_verification, person: person) }

    it "does not create a new procedure" do
      expect { subject } .not_to change { Procedures::DocumentVerification.count }
    end

    describe "the updated procedure" do
      let(:reason) { "changed" }

      it "updates the updated_at column in the existing procedure" do
        expect { subject } .to change { procedure.reload.updated_at }
      end
    end
  end
end
