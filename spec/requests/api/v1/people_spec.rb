# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let!(:person) { create(:person) }

  context "index method" do
    subject { get api_v1_people_path }
    it { expect(subject).to eq(200) }
  end

  context "show method" do
    subject { get api_v1_person_path(id: person.id) }
    it { expect(subject).to eq(200) }
  end

  context "create method" do
    let!(:person) { build(:person) }
    subject { post api_v1_people_path, params: { person: person.attributes } }
    it { expect(subject).to eq(201) }
  end

  context "update method" do
    subject { patch api_v1_person_path(id: person.id), params: { person: person.attributes } }
    it { expect(subject).to eq(200) }
  end
end
