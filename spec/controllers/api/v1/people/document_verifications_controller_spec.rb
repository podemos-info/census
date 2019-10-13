# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::DocumentVerificationsController, type: :controller do
  let(:person) { create(:person) }

  with_versioning do
    describe "create method" do
      subject(:page) { post :create, params: params }

      let(:params) { { person_id: person.qualified_id_at("participa2-1"), files: [api_attachment_format(attachment), api_attachment_format(attachment)] } }
      let(:attachment) { build(:attachment) }

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      include_examples "doesn't track the user visit"

      it "creates a new document verification procedure" do
        expect { subject } .to change(Procedure, :count).by(1)
      end

      describe "stores files received as attachments" do
        subject(:procedure) { Procedure.last }

        before { page }

        it "has saved both attachments" do
          expect(subject.attachments.count).to eq(2)
        end

        it "store attachments filenames" do
          expect(subject.attachments.map { |a| a.file.file.filename }.uniq).to eq([attachment.file.filename])
        end

        it "store attachments contents" do
          expect(subject.attachments.map { |a| a.file.file.read }.uniq).to eq([attachment.file.read])
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
        before { stub_command("People::CreateDocumentVerification", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end
  end
end
