# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::MembershipLevelsController, type: :controller do
  let(:person) { create(:person) }
  let(:membership_level) { "member" }

  with_versioning do
    describe "create method" do
      subject(:page) { post :create, params: params }

      let(:params) { { person_id: person.qualified_id_at(:decidim), membership_level: membership_level } }

      it "is valid" do
        is_expected.to have_http_status(:accepted)
        expect(subject.content_type).to eq("application/json")
      end

      it "creates a new change membership procedure" do
        expect { subject } .to change { Procedure.count }.by(1)
      end

      context "with same membership level than current" do
        let(:membership_level) { person.membership_level }

        it "has no changes" do
          is_expected.to have_http_status(:no_content)
        end

        it "doesn't create a new change membership procedure" do
          expect { subject } .to change { Procedure.count }.by(0)
        end
      end

      context "with an invalid person id" do
        before { person.delete }

        it "is not valid" do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(subject.content_type).to eq("application/json")
        end

        it "returns the errors collection" do
          expect(subject.body).to eq({ person: [{ error: "blank" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("People::CreateMembershipLevelChange", :error) }

        it "is returns an error" do
          expect(subject).to have_http_status(:internal_server_error)
          expect(subject.content_type).to eq("application/json")
        end
      end
    end
  end
end
