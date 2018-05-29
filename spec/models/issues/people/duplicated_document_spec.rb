# frozen_string_literal: true

require "rails_helper"

describe Issues::People::DuplicatedDocument, :db do
  subject(:issue) { create(:duplicated_document, other_person: existing_person) }
  let(:procedure_person) { issue.procedure.person }
  let(:existing_person) { create(:person) }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }
    let(:issue) { create(:duplicated_document, :not_evaluated, other_person: existing_person) }

    it "stores the affected people array" do
      expect { subject }.to change { issue.people.pluck(:id).sort }.from([]).to([existing_person.id, procedure_person.id].sort)
    end

    it "stores the affected procedure" do
      expect { subject }.to change { issue.procedures.to_a }.from([]).to([issue.procedure])
    end
  end

  describe "#fix!" do
    subject(:fix) do
      issue.cause = :mistake
      issue.chosen_person_id = chosen_person_id
      issue.fix!
    end

    context "when choosing procedure person" do
      let(:chosen_person_id) { procedure_person.id }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "trashes the existing person" do
        expect { subject }.to change { existing_person.reload.trashed? }.from(false).to(true)
      end

      it "is fixed for the procedure person" do
        expect { subject }.to change { issue.fixed_for?(procedure_person) }.from(false).to(true)
      end

      it "is not fixed for the existing person" do
        expect { subject }.not_to change { issue.fixed_for?(existing_person) }.from(false)
      end

      it_behaves_like "an event notifiable with hutch" do
        let(:publish_notification) do
          [
            "census.people.full_status_changed", {
              person: existing_person.qualified_id,
              state: "trashed",
              verification: "mistake"
            }
          ]
        end
      end
    end

    context "when choosing existing person" do
      let(:chosen_person_id) { existing_person.id }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "doesn't trash the existing person" do
        expect { subject }.not_to change { existing_person.reload.trashed? }.from(false)
      end

      it "is not fixed for the procedure person" do
        expect { subject }.not_to change { issue.fixed_for?(procedure_person) }.from(false)
      end

      it "is fixed for the existing person" do
        expect { subject }.to change { issue.fixed_for?(existing_person) }.from(false).to(true)
      end

      it_behaves_like "an event notifiable with hutch" do
        let(:publish_notification) do
          [
            "census.people.full_status_changed", {
              person: procedure_person.qualified_id,
              state: "trashed",
              verification: "mistake"
            }
          ]
        end
      end
    end

    context "when choosing an invalid person" do
      let(:chosen_person_id) { create(:person).id }

      it "doesn't close the issue" do
        expect { subject }.not_to change { issue.reload.closed? } .from(false)
      end

      it "doesn't mark the issue as fixed" do
        expect { subject }.not_to change { issue.reload.close_result } .from(nil)
      end

      it "doesn't trash the existing person" do
        expect { subject }.not_to change { existing_person.reload.trashed? }.from(false)
      end
      it_behaves_like "an event not notifiable with hutch"
    end
  end
end
