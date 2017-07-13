# frozen_string_literal: true

require "rails_helper"

describe "Procedures", type: :request do
  let!(:procedure) { create(:verification_document, :with_attachments) }

  context "index page" do
    before { get procedures_path }
    it { expect(response).to have_http_status(200) }
  end

  context "show page" do
    before { get procedure_path(id: procedure.id) }
    it { expect(response).to have_http_status(200) }
  end

  context "edit page" do
    before { get edit_procedure_path(id: procedure.id) }
    it { expect(response).to have_http_status(200) }
  end

  context "show processed procedure" do
    let!(:procedure) { create(:verification_document, :processed) }
    before { get procedure_path(id: procedure.id) }
    it { expect(response).to have_http_status(200) }
  end
end
