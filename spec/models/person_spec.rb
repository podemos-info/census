# frozen_string_literal: true

require "rails_helper"

describe Person, :db do
  let(:person) { build(:person) }

  subject { person }

  it { is_expected.to be_valid }

  context "is not verified" do
    it { expect(person.verified?).to eq(false) }

    it "is not memberable" do
      expect(person.memberable?).to eq(false)
    end

    it "is not young memberable" do
      expect(person.young_memberable?).to eq(false)
    end
  end

  context "a verified person" do
    let(:person) { build(:person, :verified) }

    it { expect(person.verified?).to eq(true) }

    it "is memberable" do
      expect(person.memberable?).to eq(true)
    end

    it "is not young memberable" do
      expect(person.young_memberable?).to eq(false)
    end

    context "is young" do
      let(:person) { build(:person, :verified, :young) }

      it { expect(person.verified?).to eq(true) }

      it "is not memberable" do
        expect(person.memberable?).to eq(false)
      end

      it "is young memberable" do
        expect(person.young_memberable?).to eq(true)
      end
    end
  end
end
