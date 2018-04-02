# frozen_string_literal: true

require "rails_helper"

describe PersonDecorator do
  subject { person.decorate(context: { current_admin: admin }) }
  let(:person) { build(:person) }
  let(:admin) { build(:admin) }

  it "returns the decorated scope" do
    expect(subject.scope.decorated?).to be_truthy
  end

  it "returns the decorated address scope" do
    expect(subject.address_scope.decorated?).to be_truthy
  end

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

    context "when person is cancelled" do
      let(:person) { build(:person, :cancelled, first_name: "María", last_name1: "Pérez", last_name2: "García") }

      it "returns the anonymized last names always" do
        expect(subject.last_names).to eq("P. G.")
      end

      it "returns the anonymized last names always" do
        expect(subject.full_name).to eq("P. G., María")
      end

      it "returns the anonymized last names always" do
        expect(subject.name).to eq("P. G., María")
      end
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

  describe "flags" do
    let(:person) { build(:person, verified_by_document: true) }

    it "returns the person flags" do
      expect(subject.flags).to contain_exactly(:verified_by_document)
    end
  end

  describe "options" do
    it "returns the right number of gender options" do
      expect(PersonDecorator.gender_options.count).to eq(Person.genders.count)
    end

    it "returns gender options well formatted" do
      expect(PersonDecorator.gender_options.map(&:count).uniq).to eq([2])
    end

    it "returns the right number of document type options" do
      expect(PersonDecorator.document_type_options.count).to eq(Person.document_types.count)
    end

    it "returns document type options well formatted" do
      expect(PersonDecorator.document_type_options.map(&:count).uniq).to eq([2])
    end
  end
end
