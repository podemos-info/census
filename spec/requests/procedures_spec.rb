# frozen_string_literal: true

require "rails_helper"

describe "Procedures", type: :request do
  include_context "with a devise login"
  let!(:procedure) { create(:document_verification, :with_attachments) }

  describe "index page" do
    subject(:page) { get procedures_path(params) }

    let(:params) { {} }

    it { expect(subject).to eq(200) }

    context "when ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }

      it { expect(subject).to eq(200) }
    end

    context "when ordered by type" do
      let(:params) { { order: "type_asc" } }

      it { expect(subject).to eq(200) }
    end
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get procedure_path(id: procedure.id) }

      it { expect(subject).to eq(200) }
    end

    describe "show processed procedure" do
      subject(:page) { get procedure_path(id: procedure.id) }

      let!(:procedure) { create(:document_verification, :processed) }

      it { expect(subject).to eq(200) }
    end

    describe "procedure versions page" do
      subject { get procedure_versions_path(procedure_id: procedure.id) }

      before do
        PaperTrail.request.whodunnit = create(:admin)
        procedure.update! information: procedure.information.merge(test: 1) # create a procedure version
      end

      it { expect(subject).to eq(200) }
    end
  end
end
