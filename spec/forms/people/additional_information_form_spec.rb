# frozen_string_literal: true

require "rails_helper"

describe People::AdditionalInformationForm do
  subject(:form) { described_class.new(person_id: person.id, key: key, json_value: json_value) }

  let(:person) { create(:person) }
  let(:key) { "test_key" }
  let(:value) { "test_value" }
  let(:json_value) { value.to_json }

  it { is_expected.to be_valid }
  it { expect(subject.value).to eq(value) }

  context "with an invalid key" do
    let(:key) { "with spaces" }

    it { is_expected.to be_invalid }
  end

  context "with an invalid value" do
    let(:json_value) { "not json" }

    it { is_expected.to be_invalid }
    it { expect { subject.value } .to raise_error(JSON::ParserError) }
  end

  context "with a null value" do
    let(:value) { nil }

    it { is_expected.to be_valid }
    it { expect(subject.value).to be_nil }
  end

  context "with an object value" do
    let(:value) { { "a" => 1, "b" => 2 } }

    it { is_expected.to be_valid }
    it { expect(subject.value).to eq(value) }
  end
end
