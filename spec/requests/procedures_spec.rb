# frozen_string_literal: true

require "rails_helper"

describe "Procedures", type: :request do
  include_context "devise login"
  let!(:procedure) { create(:document_verification, :with_attachments) }

  context "index page" do
    subject(:page) { get procedures_path(params) }
    let(:params) { {} }
    it { expect(subject).to eq(200) }

    context "ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }
      it { expect(subject).to eq(200) }
    end
    context "ordered by type" do
      let(:params) { { order: "type_asc" } }
      it { expect(subject).to eq(200) }
    end
  end

  with_versioning do
    context "show page" do
      subject(:page) { get procedure_path(id: procedure.id) }
      it { expect(subject).to eq(200) }
    end

    context "show processed procedure" do
      let!(:procedure) { create(:document_verification, :processed) }
      subject(:page) { get procedure_path(id: procedure.id) }
      it { expect(subject).to eq(200) }
    end

    context "procedure versions page" do
      before do
        PaperTrail.request.whodunnit = create(:admin)
        procedure.update! information: procedure.information.merge(test: 1) # create a procedure version
      end
      subject { get procedure_versions_path(procedure_id: procedure.id) }
      it { expect(subject).to eq(200) }
    end
  end
end
