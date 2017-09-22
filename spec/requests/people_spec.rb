# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  include_context "devise login"

  let!(:person) { create(:person, :verified) }

  context "index page" do
    subject { get people_path }
    it { expect(subject).to eq(200) }
  end

  context "show page" do
    let(:person) { create(:verification_document).person }
    subject { get person_path(id: person.id) }
    it { expect(subject).to eq(200) }
  end

  context "new page" do
    subject { get new_person_path }
    it { expect(subject).to eq(200) }
  end

  context "edit page" do
    subject { get edit_person_path(id: person.id) }
    it { expect(subject).to eq(200) }
  end

  context "history page" do
    subject { get history_person_path(id: person.id) }
    it { expect(subject).to eq(200) }
  end
end
