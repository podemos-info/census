# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::MembershipLevelsController, type: :controller do
  let(:person) { create(:person) }
  let(:membership_level) { "member" }

  with_versioning do
    describe "create method" do
      subject(:page) { post :create, params: params }

      let(:params) { { person_id: person.qualified_id_at("participa2-1"), membership_level: membership_level } }

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      include_examples "doesn't track the user visit"

      it "creates a new change membership procedure" do
        expect { subject } .to change(Procedure, :count).by(1)
      end

      context "with same membership level than current" do
        let(:membership_level) { person.membership_level }

        it "has no changes" do
          is_expected.to have_http_status(:no_content)
        end

        it "doesn't create a new change membership procedure" do
          expect { subject } .to change(Procedure, :count).by(0)
        end
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
        before { stub_command("People::CreateMembershipLevelChange", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end
  end
end
