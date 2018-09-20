# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  include_context "devise login"
  let(:person) { create(:person, :verified) }
  let(:current_admin) { create(:admin, :data) }

  describe "index page" do
    subject(:page) { get people_path }

    it { expect(subject).to eq(200) }
  end

  describe "edit page" do
    subject { get edit_person_path(id: person.id) }

    it { expect(subject).to eq(200) }
  end

  with_versioning do
    describe "show page" do
      subject { get person_path(id: person.id) }

      let(:person) { create(:document_verification).person }

      it { expect(subject).to eq(200) }
    end

    describe "person versions page" do
      subject { get person_versions_path(person_id: person.id) }

      before do
        PaperTrail.request.whodunnit = create(:admin)
        person.update! first_name: "#{person.first_name} A" # create a person version
      end

      it { expect(subject).to eq(200) }
    end
  end

  describe "person procedures page" do
    subject { get person_procedures_path(person_id: person.id) }

    before { procedure }

    let(:procedure) { create(:document_verification, person: person) }

    it { expect(subject).to eq(200) }
  end

  context "with a finances user" do
    let(:current_admin) { create(:admin, :finances) }

    describe "person orders page" do
      subject { get person_orders_path(person_id: person.id) }

      before { order }

      let(:order) { create(:order, person: person) }

      it { expect(subject).to eq(200) }
    end

    describe "person payment methods" do
      subject { get person_payment_methods_path(person_id: person.id) }

      before { payment_method }

      let(:payment_method) { create(:direct_debit, person: person) }

      it { expect(subject).to eq(200) }
    end
  end
end
