# frozen_string_literal: true

require "rails_helper"

describe EventDecorator do
  subject(:decorator) { event.decorate }
  let(:event) { create(:event) }

  describe "#description" do
    subject(:method) { decorator.description }

    context "dashboard view" do
      it { is_expected.to eq("") }
    end

    context "person view" do
      let(:event) { create(:event, :person_view, person: person) }
      let(:person) { create(:person).decorate }
      it { is_expected.to eq("<a href=\"/people/#{person.id}\">#{person.full_name}</a>") }
    end

    context "deleted person view" do
      let(:event) { create(:event, :person_view, person: person) }
      let(:person) { create(:person).decorate }
      it do
        person.destroy
        is_expected.to eq(person.id.to_s)
      end
    end
  end
end
