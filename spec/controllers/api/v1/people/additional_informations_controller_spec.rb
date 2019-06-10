# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::AdditionalInformationsController, type: :controller do
  let(:person) { create(:person) }
  let(:key) { "test_key" }
  let(:value) { "test_value" }

  with_versioning do
    describe "create method" do
      subject(:page) { post :create, params: params }

      let(:params) { { person_id: person.qualified_id_at(:decidim), key: key, json_value: value.to_json } }

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }
      include_examples "doesn't track the user visit"

      it "updates the person record" do
        expect { subject } .to change { person.reload.additional_information[key] } .from(nil).to(value)
      end

      context "with an invalid person id" do
        before { person.delete }

        it { expect(subject).to have_http_status(:unprocessable_entity) }
        it { expect(subject.content_type).to eq("application/json") }

        it "returns the errors collection" do
          expect(subject.body).to eq({ person: [{ error: "blank" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("People::SaveAdditionalInformation", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end
  end
end
