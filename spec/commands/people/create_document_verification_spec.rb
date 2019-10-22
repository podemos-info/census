# frozen_string_literal: true

require "rails_helper"

describe People::CreateDocumentVerification do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::DocumentVerificationForm }
  let(:valid) { true }
  let(:procedure) { Procedures::DocumentVerification.find_by(person: person) }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      prioritize?: prioritize,
      files: files
    )
  end

  let(:files) { [build(:attachment).file, build(:attachment).file] }
  let(:prioritize) { false }

  it "broadcasts :ok" do
    expect { subject } .to broadcast(:ok)
  end

  it "creates a new procedure to verify the person document" do
    expect { subject } .to change { Procedures::DocumentVerification.count } .by(1)
  end

  it "updates the person verification state" do
    expect { subject } .to change { person.reload.verification } .from("not_verified").to("verification_received")
  end

  it "doesn't set the prioritized date" do
    subject
    expect(procedure.prioritized_at).to be_nil
  end

  it_behaves_like "an event notifiable with hutch" do
    let(:publish_notification) { "census.people.full_status_changed" }
    let(:publish_notification_args) do
      {
        person: person.qualified_id,
        external_ids: person.external_ids,
        state: person.state,
        verification: "verification_received",
        membership_level: person.membership_level,
        scope_code: person.scope&.code,
        document_type: person.document_type,
        age: person.age
      }
    end
  end

  context "when prioritizing the procedure" do
    let(:prioritize) { true }

    it "sets the prioritized date" do
      subject
      expect(procedure.prioritized_at).to be_within(1.second).of Time.current
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .not_to change(Procedures::DocumentVerification, :count)
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  context "when a procedure already exists for the person" do
    before { existing_procedure }

    let(:person) { create(:person, verification: :verification_received) }
    let(:existing_procedure) { create(:document_verification, :prioritized, person: person) }
    let(:files) { [build(:attachment, :non_image).file, build(:attachment).file] }

    it "does not create a new procedure" do
      expect { subject } .not_to change(Procedures::DocumentVerification, :count)
    end

    it "updates the updated_at column in the existing procedure" do
      expect { subject } .to change { existing_procedure.attachments.pluck(:id) }
    end

    it "doesn't modify the prioritized_at column" do
      expect { subject } .not_to change { existing_procedure.reload.prioritized_at }
    end

    it_behaves_like "an event not notifiable with hutch"

    context "when prioritizing the procedure" do
      let(:prioritize) { true }

      it "sets the prioritized date" do
        expect { subject } .to change { existing_procedure.reload.prioritized_at } .to be_within(1.second).of Time.current
      end
    end
  end
end
