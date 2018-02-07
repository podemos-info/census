# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::VerificationsController, type: :controller do
  let(:person) { create(:person) }

  with_versioning do
    describe "create method" do
      let(:attachment) { build(:attachment) }
      let(:params) { { person_id: person.id, files: [api_attachment_format(attachment), api_attachment_format(attachment)] } }

      subject(:page) do
        post :create, params: params
      end

      it "is valid" do
        is_expected.to have_http_status(:created)
        expect(subject.content_type).to eq("application/json")
      end

      it "creates a new verification procedure" do
        expect { subject } .to change { Procedure.count }.by(1)
      end

      describe "stores files received as attachments" do
        before { page }
        subject(:procedure) { Procedure.last }

        it "has saved both attachments" do
          expect(subject.attachments.count).to eq(2)
        end

        it "store attachments contents" do
          subject.attachments.each do |saved_attachment|
            expect(saved_attachment.file.file.filename).to eq(attachment.file.filename)
            expect(saved_attachment.file.file.read).to eq(attachment.file.read)
          end
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
        before { stub_command("Procedures::CreateVerification", :error) }

        it "is returns an error" do
          expect(subject).to have_http_status(:internal_server_error)
          expect(subject.content_type).to eq("application/json")
        end
      end
    end
  end
end
