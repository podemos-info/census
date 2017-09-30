# frozen_string_literal: true

require "rails_helper"

describe ProcedureDecorator do
  subject(:decorator) { procedure.decorate }
  let(:processed_by) { build(:admin) }
  let(:person) { build(:person) }
  let(:procedure) { build(:verification_document, :with_attachments, person: person) }

  it "returns the decorated person" do
    expect(subject.person.decorated?).to be_truthy
  end

  it "has no processed_by person" do
    expect(subject.processed_by).to be_nil
  end

  it "returns the right number of event options" do
    expect(subject.permitted_events_options(processed_by).count).to eq(3)
  end

  it "returns event options well formatted" do
    expect(subject.permitted_events_options(processed_by).map(&:count).uniq).to eq([2])
  end

  context "#view_link" do
    let(:procedure) { create(:verification_document) }

    it "returns the process link" do
      expect(subject.view_link).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}/edit\">Procesar</a>")
    end

    it "returns the process link with the given text" do
      expect(subject.view_link("test")).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}/edit\">test</a>")
    end
  end

  context "verification document" do
    let(:person) { build(:person, first_name: "María", last_name1: "Pérez", last_name2: "García") }
    let(:procedure) { create(:verification_document, person: person) }

    it "returns the type name" do
      expect(subject.type_name).to eq("Verificación de documento")
    end

    it "returns the type name and the id when retrieving name" do
      expect(subject.name).to eq("Verificación de documento ##{procedure.id}")
    end
  end

  context "processed procedure" do
    let(:procedure) { build(:verification_document, :processed) }

    it "returns the processed_by person" do
      expect(subject.processed_by.decorated?).to be_truthy
    end

    context "#view_link" do
      let(:procedure) { create(:verification_document, :processed) }

      it "returns the process link" do
        expect(subject.view_link).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">Ver</a>")
      end

      it "returns the process link with the given text" do
        expect(subject.view_link("test")).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">test</a>")
      end
    end
  end

  context "#route_key" do
    subject(:method) { decorator.route_key }
    it { is_expected.to eq("procedures") }
  end

  context "#singular_route_key" do
    subject(:method) { decorator.singular_route_key }
    it { is_expected.to eq("procedure") }
  end
end
