# frozen_string_literal: true

require "rails_helper"

describe Issues::People::DuplicatedPerson, :db do
  subject(:issue) { create(:duplicated_person, :not_evaluated, other_person: duplicated_person) }
  let(:duplicated_person) { create(:person) }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }
    let(:person) { issue.procedure.person }

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
