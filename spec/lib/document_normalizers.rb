# frozen_string_literal: true

require "rails_helper"

describe Normalizr do
  let(:document_type) { :dni }

  subject do
    Normalizr.normalize(value, :"document_#{document_type}")
  end

  context "when normalizing a dni" do
    context "does nothing on normalized value" do
      let(:value) { "000000001R" }
      it { is_expected.to eq(value) }
    end

    context "normalizes length" do
      let(:value) { "1R" }
      is_expected.to eq("000000001R")
    end

    context "normalizes length without final letter" do
      let(:value) { "1" }
      is_expected.to eq("000000001")
    end

    context "upcases letters" do
      let(:value) { "1r" }
      is_expected.to eq("000000001R")
    end

    context "removes non-alphanumerical characters" do
      let(:value) { " . 1 - r*" }
      is_expected.to eq("000000001R")
    end

    context "handles nil values" do
      let(:value) { nil }
      is_expected.to eq(nil)
    end

    context "handles empty values" do
      let(:value) { "" }
      is_expected.to eq(nil)
    end
  end

  context "when normalizing a nie" do
    context "does nothing on normalized value" do
      let(:value) { "X00000001R" }
      it { is_expected.to eq(value) }
    end

    context "normalizes length" do
      let(:value) { "X1R" }
      is_expected.to eq("X00000001R")
    end

    context "normalizes length without final letter" do
      let(:value) { "X1" }
      is_expected.to eq("X00000001")
    end

    context "upcases letters" do
      let(:value) { "x1r" }
      is_expected.to eq("X00000001R")
    end

    context "removes non-alphanumerical characters" do
      let(:value) { "#x . 1 - r*" }
      is_expected.to eq("X00000001R")
    end

    context "handles nil values" do
      let(:value) { nil }
      is_expected.to eq(nil)
    end

    context "handles empty values" do
      let(:value) { "" }
      is_expected.to eq(nil)
    end

    context "returns nil on too short values" do
      let(:value) { "" }
      is_expected.to eq(nil)
    end
  end

  context "when normalizing a passport" do
    context "does nothing on normalized value" do
      let(:value) { "AB1234567" }
      it { is_expected.to eq(value) }
    end

    context "upcases letters" do
      let(:value) { "ab1234567" }
      is_expected.to eq("AB1234567")
    end

    context "removes non-alphanumerical characters" do
      let(:value) { "#a . b - 1234567*" }
      is_expected.to eq("AB1234567")
    end

    context "handles nil values" do
      let(:value) { nil }
      is_expected.to eq(nil)
    end

    context "handles empty values" do
      let(:value) { "" }
      is_expected.to eq(nil)
    end
  end
end
