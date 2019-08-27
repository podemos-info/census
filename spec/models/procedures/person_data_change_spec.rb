# frozen_string_literal: true

require "rails_helper"

CHANGING_COLUMNS = [:first_name, :last_name1, :last_name2, :scope_id, :address_scope_id].freeze

describe Procedures::PersonDataChange, :db do
  subject(:procedure) { create(:person_data_change, :ready_to_process, person_copy_data: person, changing_columns: changing_columns) }

  let(:changing_columns) { CHANGING_COLUMNS }
  let(:admin) { create(:admin) }
  let(:person) do
    build(:person, first_name: "changed", last_name1: "changed", document_id: "1R", email: "changed@changed.org", phone: "00000000000", document_scope: create(:scope))
  end

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.to be_acceptable_by(admin) }
  it { is_expected.to be_auto_processable }

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    CHANGING_COLUMNS.each do |attribute|
      it "sets #{attribute}" do
        expect { subject } .to change { procedure.person.send(attribute) } .to(person.send(attribute))
      end
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            age: procedure.person.age,
            document_type: procedure.person.document_type,
            person: procedure.person.qualified_id,
            state: procedure.person.state,
            membership_level: procedure.person.membership_level,
            verification: procedure.person.verification,
            scope_code: person.scope&.code
          }
        ]
      end
    end

    context "when scope column is not modified" do
      let(:changing_columns) { CHANGING_COLUMNS - [:scope_id] }

      it_behaves_like "an event not notifiable with hutch"
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    CHANGING_COLUMNS.each do |attribute|
      it "sets #{attribute}" do
        expect { subject } .not_to change { procedure.person.send(attribute) }
      end
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  with_versioning do
    context "when has accepted the procedure" do
      subject(:undo) { procedure.undo! }

      before do
        previous_person
        procedure.accept!
      end

      let(:previous_person) { procedure.person.attributes.with_indifferent_access }

      CHANGING_COLUMNS.each do |attribute|
        it "undoes unsets #{attribute}" do
          expect { subject } .to change { procedure.person.send(attribute) } .from(person.send(attribute)).to(previous_person[attribute])
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
