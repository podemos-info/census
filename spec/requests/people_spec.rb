# frozen_string_literal: true

require "rails_helper"

describe "People", type: :request do
  include_context "devise login"
  let!(:person) { create(:person, :verified) }

  context "index page" do
    subject(:page) { get people_path(params) }
    let(:params) { {} }
    it { expect(subject).to eq(200) }

    context "ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }
      it { expect(subject).to eq(200) }
    end
    context "ordered by full_document" do
      let(:params) { { order: "full_document_asc" } }
      it { expect(subject).to eq(200) }
    end
    context "ordered by scope" do
      let(:params) { { order: "scope_desc" } }
      it { expect(subject).to eq(200) }
    end
    context "ordered by flags" do
      let(:params) { { order: "flags_asc" } }
      it { expect(subject).to eq(200) }
    end
  end

  context "new page" do
    subject { get new_person_path }
    it { expect(subject).to eq(200) }
  end

  context "edit page" do
    subject { get edit_person_path(id: person.id) }
    it { expect(subject).to eq(200) }
  end

  context "person orders page" do
    let!(:order) { create(:order, person: person) }
    subject { get person_orders_path(person_id: person.id) }
    it { expect(subject).to eq(200) }
  end

  context "person payment methods" do
    let!(:payment_method) { create(:direct_debit, person: person) }
    subject { get person_payment_methods_path(person_id: person.id) }
    it { expect(subject).to eq(200) }
  end

  with_versioning do
    context "show page" do
      let(:person) { create(:verification_document).person }
      subject { get person_path(id: person.id) }
      it { expect(subject).to eq(200) }
    end

    context "person versions page" do
      before do
        PaperTrail.whodunnit = create(:admin)
        person.update_attributes! first_name: "#{person.first_name} A" # create a person version
      end
      subject { get person_versions_path(person_id: person.id) }
      it { expect(subject).to eq(200) }
    end
  end

  context "person procedures page" do
    let!(:procedure) { create(:verification_document, person: person) }
    subject { get person_procedures_path(person_id: person.id) }
    it { expect(subject).to eq(200) }
  end
end
