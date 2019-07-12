# frozen_string_literal: true

require "rails_helper"

describe Person, :db do
  subject(:person) { build(:person) }

  it { is_expected.to be_valid }

  context "when is not verified" do
    it { is_expected.not_to be_verified }

    it "is not memberable" do
      is_expected.not_to be_memberable
    end
  end

  context "when the person is verified" do
    subject(:person) { build(:person, :verified) }

    it { is_expected.to be_verified }

    it "is memberable" do
      is_expected.to be_memberable
    end

    context "when is young" do
      subject(:person) { build(:person, :verified, :young) }

      it { is_expected.to be_verified }

      it "is not memberable" do
        is_expected.not_to be_memberable
      end
    end
  end

  describe "qualified_id" do
    subject(:qualified_id) { person.qualified_id }

    let(:person) { create(:person) }

    it { is_expected.to eq("#{person.id}@census") }
  end

  describe "qualified_find" do
    subject(:qualified_find) { Person.qualified_find(qualified_id) }

    let(:person) { create(:person) }
    let(:qualified_id) { person.qualified_id }

    it { is_expected.to eq(person) }

    context "when given qualified_id is from an external system" do
      let(:qualified_id) { person.qualified_id_at(:decidim) }

      it { is_expected.to eq(person) }
    end

    context "when given qualified_id is empty" do
      let(:qualified_id) { "" }

      it { is_expected.to be_nil }
    end

    context "when given qualified_id has an invalid format" do
      let(:qualified_id) { "0" }

      it { is_expected.to be_nil }
    end

    context "when given qualified_id has an invalid identifier" do
      let(:qualified_id) { "potato@decidim" }

      it { is_expected.to be_nil }
    end

    context "when given qualified_id has an invalid external system identifier" do
      let(:qualified_id) { "1@potato" }

      it { is_expected.to be_nil }
    end
  end

  it_behaves_like(
    "a model that allows fast filter",
    first_name: ->(person) { person.first_name },
    last_names: ->(person) { [person.last_name1, person.last_name2].join(" ") },
    document: ->(person) { person.document_id },
    phone_number: ->(person) { person.phone },
    phone_number_begining: ->(person) { person.phone[0..6] }
  ) do
    let(:resource) { create(:person) }
  end
end
