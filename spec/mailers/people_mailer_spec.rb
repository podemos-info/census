# frozen_string_literal: true

require "rails_helper"

describe PeopleMailer, type: :mailer do
  describe "#affiliated" do
    subject(:email) { described_class.with(person: person).affiliated }

    let(:person) { create(:person, :member) }

    it { expect(email.to).to eq([person.email]) }
    it { expect(email.subject).to eq("Afiliación a Podemos") }
    it { expect(email.body).to match("Hola #{person.first_name}, te has afiliado a Podemos.") }

    context "when user is not a member" do
      let(:person) { create(:person) }

      it { expect(email.to).to be_nil }
    end
  end

  describe "#unaffiliated" do
    subject(:email) { described_class.with(person: person).unaffiliated }

    let(:person) { create(:person) }

    it { expect(email.to).to eq([person.email]) }
    it { expect(email.subject).to eq("Baja de la afiliación a Podemos") }
    it { expect(email.body).to match("Hola #{person.first_name}, has dado de baja tu afiliación a Podemos.") }

    context "when user is a member" do
      let(:person) { create(:person, :member) }

      it { expect(email.to).to be_nil }
    end
  end
end
