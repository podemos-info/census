# frozen_string_literal: true

require "rails_helper"

describe CallbacksController, type: :controller do
  render_views

  OK_REQUEST = <<~EOD
    <?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <XML xsi:type="xsd:string">&lt;Message&gt;&lt;Request Ds_Version=&apos;0.0&apos;&gt;&lt;Fecha&gt;15/09/2017&lt;/Fecha&gt;&lt;Hora&gt;18:06&lt;/Hora&gt;&lt;Ds_SecurePayment&gt;1&lt;/Ds_SecurePayment&gt;&lt;Ds_ExpiryDate&gt;2012&lt;/Ds_ExpiryDate&gt;&lt;Ds_Merchant_Identifier&gt;5e144f3b48196690b5c0afa0da6f113acc3c9af5&lt;/Ds_Merchant_Identifier&gt;&lt;Ds_Card_Country&gt;724&lt;/Ds_Card_Country&gt;&lt;Ds_Amount&gt;1234&lt;/Ds_Amount&gt;&lt;Ds_Currency&gt;978&lt;/Ds_Currency&gt;&lt;Ds_Order&gt;37836W000001&lt;/Ds_Order&gt;&lt;Ds_MerchantCode&gt;306003724&lt;/Ds_MerchantCode&gt;&lt;Ds_Terminal&gt;001&lt;/Ds_Terminal&gt;&lt;Ds_Response&gt;0000&lt;/Ds_Response&gt;&lt;Ds_MerchantData&gt;Test&lt;/Ds_MerchantData&gt;&lt;Ds_TransactionType&gt;0&lt;/Ds_TransactionType&gt;&lt;Ds_ConsumerLanguage&gt;1&lt;/Ds_ConsumerLanguage&gt;&lt;Ds_AuthorisationCode&gt;042428&lt;/Ds_AuthorisationCode&gt;&lt;Ds_Card_Brand&gt;1&lt;/Ds_Card_Brand&gt;&lt;/Request&gt;&lt;Signature&gt;KKtZiW6MpXKlNwl9/01VHDNtGl5Uz4//DFsMHMxaT5Y=&lt;/Signature&gt;&lt;/Message&gt;</XML>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  EOD

  OK_RESPONSE = <<~EOD
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <return xsi:type="xsd:string">&lt;Message&gt;&lt;Response Ds_Version="0.0"&gt;&lt;Ds_Response_Merchant&gt;OK&lt;/Ds_Response_Merchant&gt;&lt;/Response&gt;&lt;Signature&gt;UyffHOGPvRBVN1hj3TcwbrUZenyjorgeFYixJaBRY+w=&lt;/Signature&gt;&lt;/Message&gt;</return>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  EOD

  context "redsys payment callbacks" do
    subject(:page) { post :payments, params: { payment_processor: :redsys }, body: redsys_response.to_s }
    let!(:person) { create(:person, id: 1) }

    context "when redsys response is correct" do
      before { Timecop.freeze(Time.local(2017, 9, 15, 18, 7)) }
      after { Timecop.return }
      let(:redsys_response) { OK_REQUEST }

      it "returns ok" do
        is_expected.to be_success
      end
      it "creates a new order" do
        expect { subject } .to change { Order.count } .by(1)
      end
      it "creates a new credit card payment method" do
        expect { subject } .to change { PaymentMethods::CreditCard.count } .by(1)
      end
    end

    context "when redsys response is out of date" do
      before { Timecop.freeze(Time.local(2017, 9, 16)) }
      after { Timecop.return }
      let(:redsys_response) { OK_RESPONSE }

      it "returns ok" do
        is_expected.to be_success
      end
      it "does not create a new order" do
        expect { subject } .not_to change { Order.count }
      end
      it "does not create a new credit card payment method" do
        expect { subject } .not_to change { PaymentMethods::CreditCard.count }
      end
    end

    context "when redsys response is out of date" do
      before { Timecop.freeze(Time.local(2017, 9, 16)) }
      after { Timecop.return }
      let(:redsys_response) { OK_RESPONSE }

      it "returns ok" do
        is_expected.to be_success
      end
      it "does not create a new order" do
        expect { subject } .not_to change { Order.count }
      end
      it "does not create a new credit card payment method" do
        expect { subject } .not_to change { PaymentMethods::CreditCard.count }
      end
    end
  end
end
