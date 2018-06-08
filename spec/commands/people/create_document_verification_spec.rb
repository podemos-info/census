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

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "creates a new procedure to verify the person document" do
      expect { subject } .to change { Procedures::DocumentVerification.count } .by(1)
    end

    it "updates the person verification state" do
      expect { subject } .to change { person.reload.verification } .from("not_verified").to("verification_received")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            person: person.qualified_id,
            state: person.state,
            membership_level: person.membership_level,
            verification: "verification_received",
            scope: person.scope&.code
          }
        ]
      end
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::DocumentVerification.count }
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  context "when a procedure already exists for the person" do
    let!(:person) { create(:person, verification: :verification_received) }
    let!(:procedure) { create(:document_verification, person: person) }
    let(:files) { [build(:attachment, :non_image).file, build(:attachment).file] }

    it "does not create a new procedure" do
      expect { subject } .not_to change { Procedures::DocumentVerification.count }
    end

    it "updates the updated_at column in the existing procedure" do
      expect { subject } .to change { procedure.attachments.pluck(:id) }
    end

    it_behaves_like "an event not notifiable with hutch"
  end
end
