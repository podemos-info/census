# frozen_string_literal: true

require "rails_helper"

describe Normalizr do
  subject do
    Normalizr.normalize(value, :"document_#{document_type}")
  end

  context "when normalizing a dni" do
    let(:document_type) { :dni }

    context "does nothing on normalized value" do
      let(:value) { "00000001R" }
      it { is_expected.to eq(value) }
    end

    context "normalizes length" do
      let(:value) { "1R" }
      it { is_expected.to eq("00000001R") }
    end

    context "normalizes length without final letter" do
      let(:value) { "1" }
      it { is_expected.to eq("00000001") }
    end

    context "upcases letters" do
      let(:value) { "1r" }
      it { is_expected.to eq("00000001R") }
    end

    context "removes non-alphanumerical characters" do
      let(:value) { " . 1 - r*" }
      it { is_expected.to eq("00000001R") }
    end

    context "handles nil values" do
      let(:value) { nil }
      it { is_expected.to eq(nil) }
    end

    context "handles empty values" do
      let(:value) { "" }
      it { is_expected.to eq(nil) }
    end
  end

  context "when normalizing a nie" do
    let(:document_type) { :nie }

    context "does nothing on normalized value" do
      let(:value) { "X0000001R" }
      it { is_expected.to eq(value) }
    end

    context "normalizes length" do
      let(:value) { "X1R" }
      it { is_expected.to eq("X0000001R") }
    end

    context "normalizes length without final letter" do
      let(:value) { "X1" }
      it { is_expected.to eq("X0000001") }
    end

    context "upcases letters" do
      let(:value) { "x1r" }
      it { is_expected.to eq("X0000001R") }
    end

    context "removes non-alphanumerical characters" do
      let(:value) { "#x . 1 - r*" }
      it { is_expected.to eq("X0000001R") }
    end

    context "handles nil values" do
      let(:value) { nil }
      it { is_expected.to eq(nil) }
    end

    context "handles empty values" do
      let(:value) { "" }
      it { is_expected.to eq(nil) }
    end

    context "returns nil on too short values" do
      let(:value) { "" }
      it { is_expected.to eq(nil) }
    end
  end

  context "when normalizing a passport" do
    let(:document_type) { :passport }

    context "does nothing on normalized value" do
      let(:value) { "AB1234567" }
      it { is_expected.to eq(value) }
    end

    context "upcases letters" do
      let(:value) { "ab1234567" }
      it { is_expected.to eq("AB1234567") }
    end

    context "removes non-alphanumerical characters" do
      let(:value) { "#a . b - 1234567*" }
      it { is_expected.to eq("AB1234567") }
    end

    context "handles nil values" do
      let(:value) { nil }
      it { is_expected.to eq(nil) }
    end

    context "handles empty values" do
      let(:value) { "" }
      it { is_expected.to eq(nil) }
    end
  end
end
