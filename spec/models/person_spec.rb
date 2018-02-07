# frozen_string_literal: true

require "rails_helper"

describe Person, :db do
  subject(:person) { build(:person) }

  it { is_expected.to be_valid }

  context "is not verified" do
    it { is_expected.not_to be_verified }

    it "is not memberable" do
      is_expected.not_to be_memberable
    end
  end

  context "a verified person" do
    subject(:person) { build(:person, :verified) }

    it { is_expected.to be_verified }

    it "is memberable" do
      is_expected.to be_memberable
    end

    context "is young" do
      subject(:person) { build(:person, :verified, :young) }

      it { is_expected.to be_verified }

      it "is not memberable" do
        is_expected.not_to be_memberable
      end
    end
  end
end
