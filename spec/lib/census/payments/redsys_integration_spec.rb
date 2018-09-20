# frozen_string_literal: true

require "rails_helper"
require "census/payments/redsys_integration"

describe Census::Payments::RedsysIntegration do
  subject(:redsys) { described_class.new(params) }

  let(:settings) { Settings.payments.processors.redsys.auth }
  let(:params) do
    {
      merchant_name: "a merchant name",
      merchant_code: "a merchant login",
      terminal: "42",
      secret_key: "abcdefghijLMNOPQRSTUVW1234567890",
      notification_url: "https://participation.entity.com/payment/result",
      return_url: "https://census.entity.com/payment/callback",
      order_id: 123_456,
      product_description: "Purchase test",
      amount: 1_234
    }
  end
  let(:order_unique_id) do
    "1".rjust(12, "0")
  end

  it { is_expected.to be_valid }

  describe "#form" do
    subject(:form) { redsys.form }

    before { allow(redsys).to receive(:order_unique_id).and_return(order_unique_id) }

    let(:encoded_parameters) do
      <<~PARAMETERS.delete("\n")
        eyJEU19NRVJDSEFOVF9BTU9VTlQiOiIxMjM0IiwiRFNfTUVSQ0hBTlRfQ09OU1VNRVJMQU5HVUFHRSI6IjAwMSIsIkRT
        X01FUkNIQU5UX0NVUlJFTkNZIjoiOTc4IiwiRFNfTUVSQ0hBTlRfSURFTlRJRklFUiI6IlJFUVVJUkVEIiwiRFNfTUVS
        Q0hBTlRfTUVSQ0hBTlRDT0RFIjoiYSBtZXJjaGFudCBsb2dpbiIsIkRTX01FUkNIQU5UX01FUkNIQU5UTkFNRSI6ImEg
        bWVyY2hhbnQgbmFtZSIsIkRTX01FUkNIQU5UX01FUkNIQU5UVVJMIjoiaHR0cHM6Ly9wYXJ0aWNpcGF0aW9uLmVudGl0
        eS5jb20vcGF5bWVudC9yZXN1bHQiLCJEU19NRVJDSEFOVF9PUkRFUiI6IjAwMDAwMDAwMDAwMSIsIkRTX01FUkNIQU5U
        X1BST0RVQ1RERVNDUklQVElPTiI6IlB1cmNoYXNlIHRlc3QiLCJEU19NRVJDSEFOVF9NRVJDSEFOVERBVEEiOiJQdXJj
        aGFzZSB0ZXN0IiwiRFNfTUVSQ0hBTlRfVEVSTUlOQUwiOiI0MiIsIkRTX01FUkNIQU5UX1RSQU5TQUNUSU9OVFlQRSI6
        IjAiLCJEU19NRVJDSEFOVF9VUkxLTyI6Imh0dHBzOi8vY2Vuc3VzLmVudGl0eS5jb20vcGF5bWVudC9jYWxsYmFjayIs
        IkRTX01FUkNIQU5UX1VSTE9LIjoiaHR0cHM6Ly9jZW5zdXMuZW50aXR5LmNvbS9wYXltZW50L2NhbGxiYWNrIn0=
      PARAMETERS
    end

    it "returns a hash with an action url and a list of fields" do
      is_expected.to include(:action, :fields)
    end

    it "uses redsys test url" do
      expect(subject[:action]).to eq("https://sis-t.redsys.es:25443/sis/realizarPago")
    end

    it "includes the redsys required fields list" do
      expect(subject[:fields]).to include(:Ds_MerchantParameters, :Ds_SignatureVersion, :Ds_Signature)
    end

    it "uses a valid signature version" do
      expect(subject[:fields][:Ds_SignatureVersion]).to eq("HMAC_SHA256_V1")
    end

    it "generate a valid signature" do
      expect(subject[:fields][:Ds_Signature]).to eq("fw21jxwtrceQPv62vG+76jBTo9f2M0Q8s+2CXg7QfZ4=")
    end

    it "generates a valid parameters string" do
      expect(subject[:fields][:Ds_MerchantParameters]).to eq(encoded_parameters)
    end
  end
end
