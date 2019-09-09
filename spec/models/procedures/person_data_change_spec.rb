# frozen_string_literal: true

require "rails_helper"

describe Procedures::PersonDataChange, :db do
  subject(:procedure) do
    create(:person_data_change, :ready_to_process, person: create(:person, document_type: :dni),
                                                   person_copy_data: person,
                                                   changing_columns: changing_columns)
  end

  let(:admin) { create(:admin) }
  let(:changing_columns) do
    [
      :first_name,
      :last_name1,
      :last_name2,
      :born_at,
      :document_type,
      :document_id,
      :email,
      :phone,
      :scope_id,
      :address_scope_id
    ]
  end
  let(:person) do
    build(:person, first_name: "changed",
                   last_name1: "changed",
                   last_name2: "changed",
                   born_at: 18.years.ago,
                   document_type: :passport,
                   document_id: "ABC1234",
                   email: "changed@changed.org",
                   phone: "00000000000",
                   scope: create(:scope))
  end

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.to be_acceptable_by(admin) }
  it { is_expected.to be_auto_processable }

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "sets all changing columns" do
      expect { subject } .to(change { methods_map(procedure.person.reload, changing_columns) }
                           .to(methods_map(person, changing_columns)))
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { "census.people.full_status_changed" }
      let(:publish_notification_args) do
        {
          person: procedure.person.qualified_id,
          external_ids: procedure.person.external_ids,
          state: procedure.person.state,
          verification: procedure.person.verification,
          membership_level: procedure.person.membership_level,
          scope_code: person.scope&.code,
          document_type: person.document_type,
          age: person.age
        }
      end
    end

    [:document_type, :born_at, :scope_id].each do |column|
      context "when only #{column} is modified" do
        let(:changing_columns) { [column] }

        it_behaves_like "an event notifiable with hutch" do
          let(:publish_notification) { "census.people.full_status_changed" }
          let(:publish_notification_args) do
            {
              person: procedure.person.qualified_id,
              external_ids: procedure.person.external_ids,
              state: procedure.person.state,
              verification: procedure.person.verification,
              membership_level: procedure.person.membership_level,
              scope_code: (column == :scope_id ? person : procedure.person).scope&.code,
              document_type: (column == :document_type ? person : procedure.person).document_type,
              age: (column == :born_at ? person : procedure.person).age
            }
          end
        end
      end
    end

    context "when no event column is modified" do
      let(:changing_columns) { [:first_name] }

      it_behaves_like "an event not notifiable with hutch"
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "doesn't update the changing columns" do
      expect { subject } .not_to change { methods_map(procedure.person.reload, changing_columns) }
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

      let(:previous_person) { procedure.person.dup }

      it "undoes unsets the changing columns" do
        expect { subject } .to(change { methods_map(procedure.person.reload, changing_columns) }
                             .from(methods_map(person, changing_columns))
                             .to(methods_map(previous_person, changing_columns)))
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
