# frozen_string_literal: true

require "rails_helper"

CHANGING_COLUMNS = [:first_name, :last_name1, :last_name2, :scope_id, :address_scope_id].freeze

describe Procedures::PersonDataChange, :db do
  subject(:procedure) { create(:person_data_change, :ready_to_process, person_copy_data: person, changing_columns: changing_columns) }
  let(:changing_columns) { CHANGING_COLUMNS }
  let(:person) { build(:person, document_scope: create(:scope)) }
  let(:admin) { create(:admin) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is fully acceptable" do
    expect(subject.full_acceptable_by?(admin)).to be_truthy
  end

  it "is auto_acceptable" do
    is_expected.to be_auto_acceptable
  end

  context "when accepted" do
    CHANGING_COLUMNS.each do |attribute|
      it "sets #{attribute}" do
        expect { procedure.accept! } .to change { procedure.person.send(attribute) } .to(person.send(attribute))
      end
    end
  end

  context "when rejected" do
    CHANGING_COLUMNS.each do |attribute|
      it "sets #{attribute}" do
        expect { procedure.reject! } .not_to change { procedure.person.send(attribute) }
      end
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      CHANGING_COLUMNS.each do |attribute|
        it "undoes unsets #{attribute}" do
          expect { subject } .to change { procedure.person.send(attribute) } .from(person.send(attribute))
        end
      end
    end
  end

  describe "#possible_issues" do
    subject(:possible_issues) { procedure.possible_issues }

    {
      [:first_name] => [Issues::People::DuplicatedPerson],
      [:last_name1] => [Issues::People::DuplicatedPerson],
      [:document_id, :born_at] => [Issues::People::DuplicatedPerson, Issues::People::DuplicatedDocument],
      [:document_scope_id] => [Issues::People::DuplicatedDocument],
      [:email] => [Issues::People::UntrustedEmail],
      [:phone] => [Issues::People::UntrustedPhone],
      [:document_id, :last_name1, :email, :phone] => [Issues::People::DuplicatedPerson, Issues::People::DuplicatedDocument,
                                                      Issues::People::UntrustedEmail, Issues::People::UntrustedPhone]
    }.each do |changing_columns, possible_issues|
      context "when changing #{changing_columns.to_sentence}" do
        let(:changing_columns) { changing_columns }

        it "returns correct possible issues" do
          is_expected.to match_array(possible_issues)
        end
      end
    end
  end
end
