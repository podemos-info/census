# frozen_string_literal: true

require "rails_helper"

describe CallbacksController, type: :controller do
  render_views

  OK_REQUEST = <<~XML
    <?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <XML xsi:type="xsd:string">&lt;Message&gt;&lt;Request Ds_Version=&apos;0.0&apos;&gt;&lt;Fecha&gt;22/11/2017&lt;/Fecha&gt;&lt;Hora&gt;13:47&lt;/Hora&gt;&lt;Ds_SecurePayment&gt;1&lt;/Ds_SecurePayment&gt;&lt;Ds_ExpiryDate&gt;2012&lt;/Ds_ExpiryDate&gt;&lt;Ds_Merchant_Identifier&gt;c4e8cdd1810e52e6df5eeec4158366d47177b67e&lt;/Ds_Merchant_Identifier&gt;&lt;Ds_Card_Country&gt;724&lt;/Ds_Card_Country&gt;&lt;Ds_Amount&gt;1234&lt;/Ds_Amount&gt;&lt;Ds_Currency&gt;978&lt;/Ds_Currency&gt;&lt;Ds_Order&gt;7188000000in&lt;/Ds_Order&gt;&lt;Ds_MerchantCode&gt;306003724&lt;/Ds_MerchantCode&gt;&lt;Ds_Terminal&gt;001&lt;/Ds_Terminal&gt;&lt;Ds_Response&gt;0000&lt;/Ds_Response&gt;&lt;Ds_MerchantData&gt;dfgdssd&lt;/Ds_MerchantData&gt;&lt;Ds_TransactionType&gt;0&lt;/Ds_TransactionType&gt;&lt;Ds_ConsumerLanguage&gt;1&lt;/Ds_ConsumerLanguage&gt;&lt;Ds_AuthorisationCode&gt;280010&lt;/Ds_AuthorisationCode&gt;&lt;Ds_Card_Brand&gt;1&lt;/Ds_Card_Brand&gt;&lt;/Request&gt;&lt;Signature&gt;Vai8yGmjQwANVnOetC5d1kzVBjpi1x+JttvK0yLQr2U=&lt;/Signature&gt;&lt;/Message&gt;</XML>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  XML

  OK_REQUEST_LITERAL = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <soapenv:Body>
      <notificacion xmlns="http://notificador.webservice.sis.redsys.es">
        <datoEntrada>&lt;Message&gt;&lt;Request Ds_Version='0.0'&gt;&lt;Fecha&gt;22/11/2017&lt;/Fecha&gt;&lt;Hora&gt;18:11&lt;/Hora&gt;&lt;Ds_SecurePayment&gt;1&lt;/Ds_SecurePayment&gt;&lt;Ds_ExpiryDate&gt;2012&lt;/Ds_ExpiryDate&gt;&lt;Ds_Merchant_Identifier&gt;68af247c19c3f08329accd2e08a671f33f8dc736&lt;/Ds_Merchant_Identifier&gt;&lt;Ds_Card_Country&gt;724&lt;/Ds_Card_Country&gt;&lt;Ds_Amount&gt;1234&lt;/Ds_Amount&gt;&lt;Ds_Currency&gt;978&lt;/Ds_Currency&gt;&lt;Ds_Order&gt;2628000000ir&lt;/Ds_Order&gt;&lt;Ds_MerchantCode&gt;306003724&lt;/Ds_MerchantCode&gt;&lt;Ds_Terminal&gt;001&lt;/Ds_Terminal&gt;&lt;Ds_Response&gt;0000&lt;/Ds_Response&gt;&lt;Ds_MerchantData&gt;asdasd&lt;/Ds_MerchantData&gt;&lt;Ds_TransactionType&gt;0&lt;/Ds_TransactionType&gt;&lt;Ds_ConsumerLanguage&gt;1&lt;/Ds_ConsumerLanguage&gt;&lt;Ds_AuthorisationCode&gt;559312&lt;/Ds_AuthorisationCode&gt;&lt;Ds_Card_Brand&gt;1&lt;/Ds_Card_Brand&gt;&lt;/Request&gt;&lt;Signature&gt;3MwW/YGxC1b9ooBMNtVhEJZh+Kaa5JhOeQElfp5P5zc=&lt;/Signature&gt;&lt;/Message&gt;</datoEntrada>
      </notificacion>
    </soapenv:Body>
    </soapenv:Envelope>
  XML

  OK_RESPONSE = <<~XML.delete("\n")
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <return xsi:type="xsd:string">&lt;Message&gt;&lt;Response Ds_Version="0.0"&gt;&lt;Ds_Response_Merchant&gt;OK&lt;/Ds_Response_Merchant&gt;&lt;/Response&gt;&lt;Signature&gt;VOyxw0QiSnuJ+qw5wcud7FNa2sIbMYRoih3vgw66FKY=&lt;/Signature&gt;&lt;/Message&gt;</return>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  XML

  OK_RESPONSE_LITERAL = <<~XML.delete("\n")
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <notificacionResponse xmlns="http://notificador.webservice.sis.redsys.es">
    <notificacionReturn xmlns="http://notificador.webservice.sis.redsys.es">&lt;Message&gt;&lt;Response Ds_Version="0.0"&gt;&lt;Ds_Response_Merchant&gt;OK&lt;/Ds_Response_Merchant&gt;&lt;/Response&gt;&lt;Signature&gt;Fz4+7o+3wZxaA7V/WkfYJDXAzOh98CnPvcgAfJQZA+A=&lt;/Signature&gt;&lt;/Message&gt;</notificacionReturn>
    </notificacionResponse>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  XML

  ERROR_REQUEST = <<~XML.delete("\n")
    <?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <XML xsi:type="xsd:string">&lt;Message&gt;&lt;Request Ds_Version=&apos;0.0&apos;&gt;&lt;Fecha&gt;22/11/2017&lt;/Fecha&gt;&lt;Hora&gt;14:02&lt;/Hora&gt;&lt;Ds_SecurePayment&gt;1&lt;/Ds_SecurePayment&gt;&lt;Ds_Card_Country&gt;724&lt;/Ds_Card_Country&gt;&lt;Ds_Amount&gt;1234&lt;/Ds_Amount&gt;&lt;Ds_Currency&gt;978&lt;/Ds_Currency&gt;&lt;Ds_Order&gt;410000000iq&lt;/Ds_Order&gt;&lt;Ds_MerchantCode&gt;306003724&lt;/Ds_MerchantCode&gt;&lt;Ds_Terminal&gt;001&lt;/Ds_Terminal&gt;&lt;Ds_Response&gt;0184&lt;/Ds_Response&gt;&lt;Ds_MerchantData&gt;asdasd&lt;/Ds_MerchantData&gt;&lt;Ds_TransactionType&gt;0&lt;/Ds_TransactionType&gt;&lt;Ds_ConsumerLanguage&gt;1&lt;/Ds_ConsumerLanguage&gt;&lt;Ds_AuthorisationCode&gt;      &lt;/Ds_AuthorisationCode&gt;&lt;/Request&gt;&lt;Signature&gt;ZvMeQCa6SY8IQXLCo9maRMOC3SAOjpnW401Xf46dbM0=&lt;/Signature&gt;&lt;/Message&gt;</XML>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  XML

  ERROR_RESPONSE = <<~XML.delete("\n")
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <SOAP-ENV:Body>
    <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <return xsi:type="xsd:string">&lt;Message&gt;&lt;Response Ds_Version="0.0"&gt;&lt;Ds_Response_Merchant&gt;KO&lt;/Ds_Response_Merchant&gt;&lt;/Response&gt;&lt;Signature&gt;KFiA+67RYodyCfVzYA5fNwMJeX5+/J8GD1qTvIrF7/4=&lt;/Signature&gt;&lt;/Message&gt;</return>
    </ns1:procesaNotificacionSIS>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
  XML

  describe "redsys payment callbacks" do
    subject(:page) { post :payments, params: { payment_processor: :redsys }, body: redsys_response.to_s }

    before do
      Timecop.freeze(now)
      person && order
    end

    after { Timecop.return }

    let(:person) { create(:person, id: 1) }
    let(:now) { Time.zone.local(2017, 11, 22, 14, 5) }
    let(:order) { create(:order, :external, id: order_id) }
    let(:order_id) { 671 }

    context "when redsys response is correct" do
      let(:redsys_response) { OK_REQUEST }

      it "returns ok" do
        is_expected.to be_successful
      end
      it "updates the order state" do
        expect { subject } .to change { order.reload.state } .to("processed")
      end
      it "updates the payment method response_code" do
        expect { subject } .to change { order.reload.response_code } .to("0000")
      end
      it "responds an OK WSDL message" do
        expect(subject.body.delete("\n")) .to eq OK_RESPONSE
      end

      include_examples "doesn't track the user visit"
    end

    context "when redsys response has an invalid format" do
      let(:redsys_response) { "<WRONG DATA<!" }

      it "returns ok" do
        is_expected.to be_successful
      end
      it "does not updates the order state" do
        expect { subject } .not_to change { order.reload.state }
      end
      it "does not updates the payment method response_code" do
        expect { subject } .not_to change { order.reload.payment_method.response_code }
      end
    end

    context "when redsys response is out of date" do
      let(:now) { Time.zone.local(2017, 11, 20, 14, 5) }
      let(:redsys_response) { OK_REQUEST }

      it "returns ok" do
        is_expected.to be_successful
      end
      it "does not updates the order state" do
        expect { subject } .not_to change { order.reload.state }
      end
      it "does not updates the payment method response_code" do
        expect { subject } .not_to change { order.reload.payment_method.response_code }
      end
    end

    context "when redsys response is correct in literal style" do
      let(:now) { Time.zone.local(2017, 11, 22, 18, 15) }
      let(:redsys_response) { OK_REQUEST_LITERAL }
      let(:order_id) { 675 }

      it "returns ok" do
        is_expected.to be_successful
      end
      it "updates the order state" do
        expect { subject } .to change { order.reload.state } .to("processed")
      end
      it "updates the payment method response_code" do
        expect { subject } .to change { order.reload.payment_method.response_code } .to("0000")
      end
      it "responds an OK WSDL message" do
        expect(subject.body.delete("\n")) .to eq OK_RESPONSE_LITERAL
      end
    end

    context "when redsys response contains an error code" do
      let(:redsys_response) { ERROR_REQUEST }
      let(:order_id) { 674 }
      let(:created_issue) { Issue.last }

      it "returns ok" do
        is_expected.to be_successful
      end
      it "updates the order state" do
        expect { subject } .to change { order.reload.state } .to("error")
      end
      it "updates the payment method response_code" do
        expect { subject } .to change { order.reload.payment_method.response_code } .to("0184")
      end
      it "does not create a new issue" do
        expect { subject } .not_to change(Issue, :count)
      end
      it "responds a KO WSDL message" do
        expect(subject.body.delete("\n")) .to eq ERROR_RESPONSE
      end
    end
  end
end
