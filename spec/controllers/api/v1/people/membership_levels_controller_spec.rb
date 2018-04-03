# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::MembershipLevelsController, type: :controller do
  let(:person) { create(:person) }
  let(:membership_level) { "member" }

  with_versioning do
    describe "create method" do
      let(:attachment) { build(:attachment) }
      let(:params) { { person_id: person.qualified_id_at(:decidim), membership_level: membership_level } }

      subject(:page) do
        post :create, params: params
      end

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
        before do
          person.delete
        end

        it "is not valid" do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(subject.content_type).to eq("application/json")
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
