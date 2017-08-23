# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let!(:person) { create(:person) }

  context "create method" do
    let!(:person) { build(:person) }
    subject { post api_v1_people_path, params: { person: person.attributes, level: :member } }
    it { expect(subject).to eq(201) }
  end

  context "update method" do
    subject { patch change_membership_level_api_v1_person_path(id: person.participa_id), params: { level: :member } }
    it { expect(subject).to eq(202) }
  end
end
