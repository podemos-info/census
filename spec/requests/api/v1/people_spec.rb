# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  let(:person) { build(:person) }

  with_versioning do
    describe "create method" do
      subject { post api_v1_people_path, params: { person: {} } }

      it "needs extra parameters" do
        expect(subject).to eq(422)
      end

      include_examples "only authorized api clients"
    end

    describe "update method" do
      subject { post api_v1_person_membership_levels_path(person_id: person.qualified_id_at(:decidim)), params: { membership_level: "member" } }

      let(:person) { create(:person) }

      it { expect(subject).to eq(202) }

      include_examples "only authorized api clients"
    end
  end
end
