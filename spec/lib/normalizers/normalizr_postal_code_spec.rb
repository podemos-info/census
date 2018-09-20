# frozen_string_literal: true

require "rails_helper"

describe Normalizr do
  subject(:normalizr) { described_class.normalize(value, :spanish_postal_code) }

  context "with normalized value" do
    let(:value) { "12345" }

    it { is_expected.to eq(value) }
  end

  context "with short codes" do
    let(:value) { "1234" }

    it { is_expected.to eq("01234") }
  end

  context "with very short codes" do
    let(:value) { "123" }

    it { is_expected.to eq("123") }
  end
end
