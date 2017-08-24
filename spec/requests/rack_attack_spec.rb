# frozen_string_literal: true

require "rails_helper"

describe "Rack attack", type: :request do
  context "fail2ban rule" do
    before do
      use_ip "PENTESTER"
    end

    subject do
      get "/wp-admin"
    end

    it "blocks pentester IP for only one request" do
      expect(subject).to eq(403)
      expect(get("/")).to eq(200)
    end

    context "blocks pentester IP on repeated requests" do
      subject do
        3.times { get "/wp-admin" }
        get "/"
      end
      it { expect(subject).to eq(403) }
    end
  end

  context "throttle too many request from the same IP" do
    before do
      use_ip "ANNOYER"
    end

    subject do
      300.times { get "/" }
      get "/"
    end
    it { expect(subject).to eq(429) }
  end
end
