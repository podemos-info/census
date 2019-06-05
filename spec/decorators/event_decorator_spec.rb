# frozen_string_literal: true

require "rails_helper"

describe EventDecorator do
  subject(:decorator) { event.decorate(context: { current_admin: admin }) }

  let(:event) { create(:event) }
  let(:decorated_person) { person.decorate(context: { current_admin: admin }) }
  let(:person) { create(:person) }
  let(:admin) { build(:admin) }

  describe "#name" do
    subject(:method) { decorator.name }

    it { is_expected.to eq("Ver portada") }

    context "when is a person event" do
      let(:event) { create(:event, :person_view, person: person) }

      it { is_expected.to eq("Ver persona") }
    end

    context "when is a security event" do
      let(:event) { create(:event, :security_report) }

      it { is_expected.to eq("Informe de seguridad") }
    end
  end

  describe "#description" do
    subject(:method) { decorator.description }

    it { is_expected.to eq("") }

    context "when is a person event" do
      let(:event) { create(:event, :person_view, person: person) }

      it { is_expected.to eq("<a href=\"/people/#{person.id}\">#{decorated_person.full_name}</a>") }

      context "when person is cancelled" do
        let(:person) { create(:person, :cancelled) }

        it { is_expected.to eq(decorated_person.full_name) }
      end
    end

    context "when is a people search" do
      let(:event) { create(:event, :people_search, q: { "first_name_contains" => "alb" }) }

      it { is_expected.to eq("Nombre contiene 'alb'") }
    end
  end
end
