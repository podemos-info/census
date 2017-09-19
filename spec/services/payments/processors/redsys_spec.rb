# frozen_string_literal: true

require "rails_helper"

describe Payments::Processors::Redsys do
  subject(:processor) { described_class.new }

  describe "#parse_error_type" do
    subject(:method) { processor.parse_error_type(response) }
    let(:response) { instance_double(ActiveMerchant::Billing::Response, params: { "ds_response" => response_code }) }

    context "with a success response code" do
      let(:response_code) { "0000" }
      it { is_expected.to eq(:ok) }
    end

    context "with a warning response code" do
      let(:response_code) { "0102" }
      it { is_expected.to eq(:warning) }
    end

    context "with a error response code" do
      let(:response_code) { "0118" }
      it { is_expected.to eq(:error) }
    end

    context "with an unknown response code" do
      let(:response_code) { "9999" }
      it { is_expected.to eq(:unknown) }
    end
  end
end
