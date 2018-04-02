# frozen_string_literal: true

require "rails_helper"

describe EventDecorator do
  subject(:decorator) { event.decorate(context: { current_admin: admin }) }

  let(:event) { create(:event) }
  let(:decorated_person) { person.decorate(context: { current_admin: admin }) }
  let(:person) { create(:person) }
  let(:admin) { build(:admin) }

  describe "#description" do
    subject(:method) { decorator.description }

    context "dashboard view" do
      it { is_expected.to eq("") }
    end

    context "person view" do
      let(:event) { create(:event, :person_view, person: person) }
      it { is_expected.to eq("<a href=\"/people/#{person.id}\">#{decorated_person.full_name}</a>") }
    end

    context "cancelled person view" do
      let(:event) { create(:event, :person_view, person: person) }
      let(:person) { create(:person, :cancelled) }
      it { is_expected.to eq(decorated_person.full_name) }
    end
  end
end
