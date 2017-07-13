# frozen_string_literal: true

require "rails_helper"

describe ProcedureDecorator do
  let(:person) { build(:person) }
  let(:procedure) { build(:verification_document, person: person) }
  subject { procedure.decorate }

  it "returns the decorated person" do
    expect(subject.person.decorated?).to be_truthy
  end

  it "has no processed_by person" do
    expect(subject.processed_by).to be_nil
  end

  it "returns the right number of event options" do
    expect(subject.available_events_options.count).to eq(3)
  end

  it "returns event options well formatted" do
    expect(subject.available_events_options.map(&:count).uniq).to eq([2])
  end

  context "verification document" do
    let(:person) { build(:person, first_name: "María", last_name1: "Pérez", last_name2: "García") }
    let(:procedure) { build(:verification_document, person: person) }

    it "returns the type name" do
      expect(subject.type_name).to eq("Verificación de documento")
    end

    it "returns the type name and person name when casting to string" do
      expect(subject.to_s).to eq("Verificación de documento - Pérez García, María")
    end
  end

  context "processed procedure" do
    let(:procedure) { build(:verification_document, :processed) }

    it "returns the processed_by person" do
      expect(subject.processed_by.decorated?).to be_truthy
    end
  end
end
