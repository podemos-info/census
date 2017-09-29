# frozen_string_literal: true

require "rails_helper"

describe "Procedures", type: :request do
  include_context "devise login"

  let!(:procedure) { create(:verification_document, :with_attachments) }

  context "index page" do
    subject { get procedures_path }
    it { expect(subject).to eq(200) }
  end

  context "edit page" do
    subject { get edit_procedure_path(id: procedure.id) }
    it { expect(subject).to eq(200) }
  end

  with_versioning do
    context "show page" do
      subject { get procedure_path(id: procedure.id) }
      it { expect(subject).to eq(200) }
    end

    context "show processed procedure" do
      let!(:procedure) { create(:verification_document, :processed) }
      subject { get procedure_path(id: procedure.id) }
      it { expect(subject).to eq(200) }
    end

    context "procedure versions page" do
      before do
        PaperTrail.whodunnit = create(:admin)
        procedure.update_attributes! information: procedure.information.merge(test: 1) # create a procedure version
      end
      subject { get procedure_versions_path(procedure_id: procedure.id) }
      it { expect(subject).to eq(200) }
    end
  end
end
