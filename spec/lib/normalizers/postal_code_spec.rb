# frozen_string_literal: true

require "rails_helper"

describe Normalizr do
  subject(:normalizr) { Normalizr.normalize(value, :spanish_postal_code) }

  context "does nothing on normalized value" do
    let(:value) { "12345" }
    it { is_expected.to eq(value) }
  end

  context "normalizes length" do
    let(:value) { "1234" }
    it { is_expected.to eq("01234") }
  end

  context "doesn't normalize length on very short codes" do
    let(:value) { "123" }
    it { is_expected.to eq("123") }
  end
end
