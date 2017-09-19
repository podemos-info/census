# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let(:person) { build(:person) }

  context "create method" do
    subject { post api_v1_people_path, params: { person: {} } }

    it "needs extra parameters" do
      expect(subject).to eq(422)
    end

    include_examples "only authorized api clients"
  end

  context "update method" do
    let(:person) { create(:person) }
    subject { patch change_membership_level_api_v1_person_path(id: person.participa_id), params: { level: "member" } }

    it { expect(subject).to eq(202) }

    include_examples "only authorized api clients"
  end
end
