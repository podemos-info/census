# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::PhoneVerificationsController, type: :controller do
  let(:person) { create(:person) }

  describe "new method" do
    subject(:page) { get :new, params: params }

    let(:params) { { person_id: person.qualified_id_at(:decidim), phone: phone } }
    let(:phone) { nil }

    include_context "when sending SMSs"

    it { is_expected.to have_http_status(:accepted) }
    it { expect(subject.content_type).to eq("application/json") }
    include_examples "doesn't track the user visit"

    it_behaves_like "an SMS is sent" do
      let(:to) { person.phone }
      let(:sms_service_params) { hash_including(to: to) }
    end

    context "with an invalid person id" do
      before { person.delete }

      it { expect(subject).to have_http_status(:unprocessable_entity) }
      it { expect(subject.content_type).to eq("application/json") }

      it "returns the errors collection" do
        expect(subject.body).to eq({ person: [{ error: "blank" }] }.to_json)
      end
    end

    context "when sending the message fails" do
      before { stub_command("People::StartPhoneVerification", :error) }

      it { expect(subject).to have_http_status(:internal_server_error) }
      it { expect(subject.content_type).to eq("application/json") }
    end
  end

  describe "create method" do
    subject(:page) { post :create, params: params }

    let(:params) { { person_id: qualified_id, phone: phone, received_code: received_code } }
    let(:qualified_id) { person.qualified_id_at(:decidim) }
    let(:phone) { nil }
    let(:received_code) { People::ConfirmPhoneVerificationForm.new(person_id: person.id, phone: phone).otp_code }

    it { is_expected.to have_http_status(:accepted) }
    it { expect(subject.content_type).to eq("application/json") }

    it "creates a new phone verification procedure" do
      expect { subject } .to change(Procedures::PhoneVerification, :count).by(1)
    end

    describe "stores procedure phone" do
      subject(:procedure) { Procedures::PhoneVerification.last }

      before { page }

      it { expect(subject.phone).to eq(person.phone) }

      context "when receives a phone number" do
        let(:phone) { build(:person).phone }

        it { expect(subject.phone).to eq(phone) }
      end
    end

    context "with an received code" do
      let(:received_code) { "123456" }

      it { expect(subject).to have_http_status(:unprocessable_entity) }
      it { expect(subject.content_type).to eq("application/json") }

      it "returns the errors collection" do
        expect(subject.body).to eq({ received_code: [{ error: "invalid" }] }.to_json)
      end
    end

    context "with an invalid person id" do
      before { person.delete }

      let(:received_code) { "NANANANA" }

      it { expect(subject).to have_http_status(:unprocessable_entity) }
      it { expect(subject.content_type).to eq("application/json") }

      it "returns the errors collection" do
        expect(subject.body).to eq({ person: [{ error: "blank" }] }.to_json)
      end
    end

    context "when saving fails" do
      before { stub_command("People::CreatePhoneVerification", :error) }

      it { expect(subject).to have_http_status(:internal_server_error) }
      it { expect(subject.content_type).to eq("application/json") }
    end
  end
end
