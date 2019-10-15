# frozen_string_literal: true

require "rails_helper"

describe ProcedureDecorator do
  subject(:decorator) { procedure.decorate(context: { current_admin: admin }) }

  let(:admin) { build(:admin) }
  let(:person) { create(:person) }
  let(:procedure) { build(:document_verification, :with_attachments, person: person) }

  it { expect(subject.person).to be_decorated }

  it "has no processed_by person" do
    expect(subject.processed_by).to be_nil
  end

  it "returns the right number of event options" do
    expect(subject.actions_options(admin: admin).count).to eq(3)
  end

  it "returns event options well formatted" do
    expect(subject.actions_options(admin: admin).map(&:count).uniq).to eq([2])
  end

  describe "#link" do
    let(:procedure) { create(:document_verification) }

    it "returns the process link" do
      expect(subject.link).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">Procesar</a>")
    end

    it "returns the process link with the given text" do
      expect(subject.link("test")).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">test</a>")
    end

    context "when person procedure is cancelled" do
      let(:procedure) { create(:document_verification, :cancelled_person) }

      it "doesn't return the process link" do
        expect(subject.link).to be_nil
      end

      it "return the given text instead of the process link" do
        expect(subject.link("test")).to eq("test")
      end
    end

    context "when procedure is processed" do
      let(:procedure) { create(:document_verification, :processed) }

      it { expect(subject.processed_by).to be_decorated }

      it "returns the process link" do
        expect(subject.link).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">Ver</a>")
      end

      it "returns the process link with the given text" do
        expect(subject.link("test")).to eq("<a class=\"member_link\" href=\"/procedures/#{procedure.id}\">test</a>")
      end

      context "when person procedure is cancelled" do
        let(:procedure) { create(:document_verification, :processed, :cancelled_person) }

        it "doesn't return the process link" do
          expect(subject.link).to be_nil
        end

        it "return the given text instead of the process link" do
          expect(subject.link("test")).to eq("test")
        end
      end
    end
  end

  describe "#comment" do
    subject { decorator.comment }

    let(:procedure) { create(:document_verification, :processed, comment: comment) }
    let(:comment) { "prueba" }

    it { is_expected.to eq(comment) }

    context "when procedure was auto processed" do
      let(:comment) { "auto_accepted" }

      it { is_expected.to eq("Procedimiento aceptado de manera automática.") }
    end
  end

  describe "#summary" do
    subject { decorator.summary }

    let(:procedure) { create(:document_verification) }

    it { is_expected.to eq("") }

    context "when procedure is a membership level change" do
      let(:procedure) { create(:membership_level_change) }

      it { is_expected.to eq("simpatizante &rarr; afiliada") }
    end
  end

  context "with a document verification" do
    let(:person) { build(:person, first_name: "María", last_name1: "Pérez", last_name2: "García") }
    let(:procedure) { create(:document_verification, person: person) }

    it "returns the type name" do
      expect(subject.type_name).to eq("Verificación de documento")
    end

    it "returns the type name and the id when retrieving name" do
      expect(subject.name).to eq("Verificación de documento ##{procedure.id}")
    end
  end

  describe "#route_key" do
    subject(:method) { decorator.route_key }

    it { is_expected.to eq("procedures") }
  end

  describe "#singular_route_key" do
    subject(:method) { decorator.singular_route_key }

    it { is_expected.to eq("procedure") }
  end

  describe "#person_changeset" do
    subject(:method) { decorator.person_changeset }

    it { is_expected.to eq(created_at: "", updated_at: "", verification: "") }

    context "when procedure is can't be accepted" do
      before { person.verify! }

      it { is_expected.to eq({}) }
    end
  end
end
