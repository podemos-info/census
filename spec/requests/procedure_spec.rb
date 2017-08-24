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
end