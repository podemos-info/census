# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let(:person) { build(:person) }

  context "create method" do
    subject { post api_v1_people_path, params: { person: person.attributes, level: :member } }
    it { expect(subject).to eq(201) }

    include_examples "only authorized clients"
  end

  context "update method" do
    let(:person) { create(:person) }
    subject { patch change_membership_level_api_v1_person_path(id: person.participa_id), params: { level: :member } }
    it { expect(subject).to eq(202) }

    include_examples "only authorized clients"
  end
end
