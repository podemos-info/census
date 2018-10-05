# frozen_string_literal: true

require "rails_helper"

describe People::CreatePhoneVerification do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::ConfirmPhoneVerificationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      phone: phone
    )
  end

  let(:phone) { nil }

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "creates a new procedure to verify the person phone" do
      expect { subject } .to change { Procedures::PhoneVerification.count } .by(1)
    end

    it "updates the person phone verification state" do
      expect { subject } .to change { person.reload.phone_verification } .from("not_verified").to("verified")
    end

    context "when is also used to change the person data" do
      let(:phone) { build(:person).phone }

      it "updates the person phone verification state" do
        expect { subject } .to change { person.reload.phone }
      end
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .not_to change(Procedures::PhoneVerification, :count)
    end
  end

  context "when a procedure already exists for the person" do
    let(:phone) { build(:person).phone }
    let!(:procedure) { create(:phone_verification, person: person) }

    it "does not create a new procedure" do
      expect { subject } .not_to change(Procedures::DocumentVerification, :count)
    end

    it "updates the phone column in the existing procedure" do
      expect { subject } .to change { procedure.reload.phone }
    end
  end
end
