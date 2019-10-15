# frozen_string_literal: true

require "rails_helper"

describe Api::V1::People::ProceduresController, type: :controller do
  describe "retrieve person pending procedures methods" do
    subject(:endpoint) { get :index, params: { person_id: person.qualified_id_at("participa2-1") } }

    before { procedure1 && procedure2 }

    let(:person) { create(:person) }
    let(:procedure1) { create(:document_verification, person: person) }
    let(:procedure2) { create(:membership_level_change, person: person) }

    it { is_expected.to be_successful }

    include_examples "doesn't track the user visit"

    context "with returned data" do
      subject(:response) { JSON.parse(endpoint.body) }

      it "include both person's procedures" do
        expect(subject.count).to eq(2)
      end

      it "each returned procedure includes only id, name and type" do
        subject.each do |payment_method|
          expect(payment_method.keys) .to contain_exactly("id", "type", "state", "information")
        end
      end

      context "with processed procedures" do
        let(:procedure1) { create(:document_verification, :processed, person: person) }

        it "include only one person's procedures" do
          expect(subject.count).to eq(1)
        end
      end
    end
  end
end
