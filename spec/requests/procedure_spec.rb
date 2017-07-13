# frozen_string_literal: true

require "rails_helper"

describe "Procedures", type: :request do
  let!(:procedure) { create(:verification_document, :with_attachments) }

  context "index page" do
    subject { get procedures_path }
    it { expect(subject).to eq(200) }
  end

  context "show page" do
    subject { get procedure_path(id: procedure.id) }
    it { expect(subject).to eq(200) }
  end

  context "edit page" do
    subject { get edit_procedure_path(id: procedure.id) }
    it { expect(subject).to eq(200) }
  end

  context "show processed procedure" do
    let!(:procedure) { create(:verification_document, :processed) }
    subject { get procedure_path(id: procedure.id) }
    it { expect(subject).to eq(200) }
  end

  describe "undoable procedure" do
    before do
      ProcessProcedure.call(procedure, "accept", Person.first)
    end

    context "show procedure" do
      subject { get procedure_path(id: procedure.id) }
      it { expect(subject).to eq(200) }
    end
    context "undo procedure" do
      subject { patch undo_procedure_path(id: procedure.id) }
      it { expect(subject).to eq(302) }
    end
  end
end
