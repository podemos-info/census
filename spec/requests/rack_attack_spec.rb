# frozen_string_literal: true

require "rails_helper"

describe "Rack attack", type: :request do
  describe "fail2ban rule" do
    subject { get "/" }

    before do
      override_ip "PENTESTER"
      tries.times { get "/wp-admin" }
    end

    let(:tries) { 1 }

    it { is_expected.to eq(302) }

    context "when pentester IP made repeated requests" do
      let(:tries) { 3 }

      it { is_expected.to eq(403) }
    end
  end

  describe "throttle too many request from the same IP" do
    subject { get "/" }

    before do
      override_ip "ANNOYER"
      tries.times { get "/" }
    end

    let(:tries) { 10 }

    it { is_expected.to eq(429) }
  end
end
