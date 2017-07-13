# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let!(:person) { create(:person) }

  context "index page" do
    before { get people_path }
    it { expect(response).to have_http_status(200) }
  end

  context "show page" do
    before { get person_path(id: person.id) }
    it { expect(response).to have_http_status(200) }
  end

  context "new page" do
    before { get new_person_path }
    it { expect(response).to have_http_status(200) }
  end

  context "edit page" do
    before { get edit_person_path(id: person.id) }
    it { expect(response).to have_http_status(200) }
  end
end
