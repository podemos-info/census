# frozen_string_literal: true

require "rails_helper"

describe People::SaveAdditionalInformation do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::AdditionalInformationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      key: key,
      value: value
    )
  end

  let(:key) { "test_key" }
  let(:value) { "test_value" }

  it { expect { subject } .to broadcast(:ok) }

  it "saves the given information" do
    expect { subject } .to change { person.reload.additional_information[key] } .from(nil).to(value)
  end

  context "when information already exists" do
    let!(:person) { create(:person, additional_information: { key => "prev_value" }) }

    it { expect { subject } .to broadcast(:ok) }

    it "saves the given information" do
      expect { subject } .to change { person.reload.additional_information[key] } .from("prev_value").to(value)
    end

    context "when the new value is null" do
      let(:value) { nil }

      it { expect { subject } .to broadcast(:ok) }

      it "saves the given information" do
        expect { subject } .to change { person.reload.additional_information[key] } .from("prev_value").to(value)
      end
    end
  end

  context "when value is not a string" do
    let(:value) { { "a" => 1, "b" => 2 } }

    it { expect { subject } .to broadcast(:ok) }

    it "saves the given information" do
      expect { subject } .to change { person.reload.additional_information[key] } .from(nil).to(value)
    end
  end
end
