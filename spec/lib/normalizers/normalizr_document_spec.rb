# frozen_string_literal: true

require "rails_helper"

describe Normalizr do
  subject(:normalizr) { described_class.normalize(value, :"document_#{document_type}") }

  context "when normalizing a dni" do
    let(:document_type) { :dni }

    context "with a normalized value" do
      let(:value) { "00000001R" }

      it { is_expected.to eq(value) }
    end

    context "with a short value" do
      let(:value) { "1R" }

      it { is_expected.to eq("00000001R") }
    end

    context "without final letter" do
      let(:value) { "1" }

      it { is_expected.to eq("00000001") }
    end

    context "with lower case letter" do
      let(:value) { "1r" }

      it { is_expected.to eq("00000001R") }
    end

    context "with non-alphanumerical characters" do
      let(:value) { " . 1 - r*" }

      it { is_expected.to eq("00000001R") }
    end

    context "with an empty value" do
      let(:value) { "" }

      it { is_expected.to eq("") }
    end
  end

  context "when normalizing a nie" do
    let(:document_type) { :nie }

    context "with a normalized value" do
      let(:value) { "X0000001R" }

      it { is_expected.to eq(value) }
    end

    context "with a short value" do
      let(:value) { "X1R" }

      it { is_expected.to eq("X0000001R") }
    end

    context "without final letter" do
      let(:value) { "X1" }

      it { is_expected.to eq("X0000001") }
    end

    context "with lower case letters" do
      let(:value) { "x1r" }

      it { is_expected.to eq("X0000001R") }
    end

    context "with non-alphanumerical characters" do
      let(:value) { "#x . 1 - r*" }

      it { is_expected.to eq("X0000001R") }
    end

    context "with an empty value" do
      let(:value) { "" }

      it { is_expected.to eq("") }
    end
  end

  context "when normalizing a passport" do
    let(:document_type) { :passport }

    context "with a normalized value" do
      let(:value) { "AB1234567" }

      it { is_expected.to eq(value) }
    end

    context "with lower case letters" do
      let(:value) { "ab1234567" }

      it { is_expected.to eq("AB1234567") }
    end

    context "with non-alphanumerical characters" do
      let(:value) { "#a . b - 1234567*" }

      it { is_expected.to eq("AB1234567") }
    end

    context "with an empty value" do
      let(:value) { "" }

      it { is_expected.to eq("") }
    end
  end
end
