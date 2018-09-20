# frozen_string_literal: true

require "rails_helper"

describe PersonDecorator do
  subject { person.decorate(context: { current_admin: admin }) }

  let(:person) { build(:person) }
  let(:admin) { build(:admin) }

  it { expect(subject.scope).to be_decorated }
  it { expect(subject.address_scope).to be_decorated }

  describe "name composition" do
    let(:person) { build(:person, first_name: "María", last_name1: "Pérez", last_name2: "García") }

    it "returns the last names" do
      expect(subject.last_names).to eq("Pérez García")
    end

    it "returns the full name" do
      expect(subject.full_name).to eq("Pérez García, María")
    end

    it "returns the full name when retrieving name" do
      expect(subject.name).to eq("Pérez García, María")
    end
  end

  describe "document composition" do
    let(:person) { build(:person, document_type: "dni", document_id: "00000001R") }

    it "returns the document type name" do
      expect(subject.document_type_name).to eq("DNI")
    end

    it "returns the full document" do
      expect(subject.full_document).to eq("DNI - 00000001R")
    end
  end

  describe "gender" do
    let(:person) { build(:person, gender: "female") }

    it "returns the gender name" do
      I18n.locale = "es"
      expect(subject.gender_name).to eq("Femenino")
    end
  end

  describe "#gender_options" do
    subject(:options) { described_class.gender_options }

    it "returns the right number of gender options" do
      expect(options.count).to eq(Person.genders.count)
    end

    it "returns gender options well formatted" do
      expect(options.map(&:count).uniq).to eq([2])
    end
  end

  describe "#document_type_options" do
    subject(:options) { described_class.document_type_options }

    it "returns the right number of document type options" do
      expect(options.count).to eq(Person.document_types.count)
    end

    it "returns document type options well formatted" do
      expect(options.map(&:count).uniq).to eq([2])
    end
  end

  context "when person is cancelled" do
    let(:person) { build(:person, :cancelled, first_name: "María", last_name1: "Pérez", last_name2: "García") }

    describe "names anonymization" do
      it { expect(subject.last_name1).to eq("P.") }
      it { expect(subject.last_name2).to eq("G.") }
      it { expect(subject.last_names).to eq("P. G.") }
      it { expect(subject.full_name).to eq("P. G., María") }
      it { expect(subject.name).to eq("P. G., María") }
    end

    describe "sensible fields" do
      [:document_type, :document_id, :full_document_scope, :born_at, :address, :postal_code, :email, :phone].each do |field|
        it "#{field} returns restricted access message" do
          expect(subject.send(field)).to eq("[Datos no accesibles]")
        end
      end
    end
  end
end
