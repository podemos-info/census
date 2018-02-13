# frozen_string_literal: true

require "rails_helper"

describe Issues::People::DuplicatedPerson, :db do
  subject(:issue) { create(:duplicated_person, :not_evaluated) }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }
    let(:person) { issue.procedure.person }
    let!(:duplicated_person) { create(:person, born_at: person.born_at, first_name: person.first_name, last_name1: person.last_name1, last_name2: person.last_name2) }

    it "stores the affected people array" do
      subject
      expect(issue.people).to contain_exactly(person, duplicated_person)
    end

    it "stores the affected procedure" do
      subject
      expect(issue.procedures).to contain_exactly(issue.procedure)
    end
  end
end
