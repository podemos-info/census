# frozen_string_literal: true

require "rails_helper"

describe Issues::People::DuplicatedVerifiedPhone, :db do
  subject(:issue) { create(:duplicated_verified_phone, issuable: verification, other_person: already_verified_person) }

  before do
    previous_verification && rejected_previous_verification && already_verified_person
  end

  let(:verification) { create(:phone_verification, person: procedure_person, phone: phone) }
  let(:procedure_person) { create(:person, phone: phone) }

  let(:already_verified_person) { create(:person, :phone_verified) }

  let(:previous_verification) { create(:phone_verification, :processed, state: :accepted, phone: phone) }
  let(:previously_verified_person) { previous_verification.person }

  let(:rejected_previous_verification) { create(:phone_verification, :processed, state: :rejected, phone: phone) }
  let(:previously_non_verified_person) { rejected_previous_verification.person }

  let(:phone) { already_verified_person.phone }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }

    let(:issue) { create(:duplicated_verified_phone, :not_evaluated, issuable: verification, other_person: already_verified_person) }

    it "stores the affected people array" do
      expect { subject }.to change { issue.people.pluck(:id).sort }.from([]).to([already_verified_person.id, procedure_person.id, previously_verified_person.id].sort)
    end

    it "stores the affected procedure" do
      expect { subject }.to change { issue.procedures.to_a }.from([]).to([issue.procedure])
    end
  end

  describe "#fix!" do
    subject(:fix) do
      issue.fill
      issue.chosen_person_ids = chosen_person_ids
      issue.fix!
    end

    context "when choosing the procedure person" do
      let(:chosen_person_ids) { [procedure_person.id] }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "reassigns the phone of the already verified person" do
        expect { subject }.to change { already_verified_person.reload.phone_verification }.from("verified").to("reassigned")
      end

      it "trashes the previously verified person" do
        expect { subject }.to change { previously_verified_person.reload.trashed? }.from(false).to(true)
      end

      it "is fixed for the procedure person" do
        expect { subject }.to change { issue.fixed_for?(procedure_person) }.from(false).to(true)
      end

      it "is not fixed for the existing person" do
        expect { subject }.not_to change { issue.fixed_for?(already_verified_person) }.from(false)
      end

      it "is not fixed for the previously verified person" do
        expect { subject }.not_to change { issue.fixed_for?(previously_verified_person) }.from(false)
      end
    end

    context "when choosing the already verified person" do
      let(:chosen_person_ids) { [already_verified_person.id] }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "doesn't reassigns the phone of the already verified person" do
        expect { subject }.not_to change { already_verified_person.reload.phone_verification }
      end

      it "trashes the previously verified person" do
        expect { subject }.to change { previously_verified_person.reload.trashed? }.from(false).to(true)
      end

      it "is not fixed for the procedure person" do
        expect { subject }.not_to change { issue.fixed_for?(procedure_person) }.from(false)
      end

      it "is fixed for the already verified person" do
        expect { subject }.to change { issue.fixed_for?(already_verified_person) }.from(false).to(true)
      end

      it "is not fixed for the previously verified person" do
        expect { subject }.not_to change { issue.fixed_for?(previously_verified_person) }.from(false)
      end
    end

    context "when choosing the previously verified person" do
      let(:chosen_person_ids) { [previously_verified_person.id] }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "reassigns the phone of the already verified person" do
        expect { subject }.to change { already_verified_person.reload.phone_verification }.from("verified").to("reassigned")
      end

      it "doesn't trashes the previously verified person" do
        expect { subject }.not_to change { previously_verified_person.reload.trashed? }
      end

      it "is not fixed for the procedure person" do
        expect { subject }.not_to change { issue.fixed_for?(procedure_person) }.from(false)
      end

      it "is not fixed for the already verified person" do
        expect { subject }.not_to change { issue.fixed_for?(already_verified_person) }.from(false)
      end

      it "is fixed for the previously verified person" do
        expect { subject }.to change { issue.fixed_for?(previously_verified_person) }.from(false).to(true)
      end
    end

    context "when choosing all the people" do
      let(:chosen_person_ids) { [already_verified_person.id, procedure_person.id, previously_verified_person.id] }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "doesn't reassigns the phone of the already verified person" do
        expect { subject }.not_to change { already_verified_person.reload.phone_verification }
      end

      it "doesn't trashes the previously verified person" do
        expect { subject }.not_to change { previously_verified_person.reload.trashed? }
      end

      it "is fixed for the procedure person" do
        expect { subject }.to change { issue.fixed_for?(procedure_person) }.from(false).to(true)
      end

      it "is fixed for the already verified person" do
        expect { subject }.to change { issue.fixed_for?(already_verified_person) }.from(false).to(true)
      end

      it "is fixed for the previously verified person" do
        expect { subject }.to change { issue.fixed_for?(previously_verified_person) }.from(false).to(true)
      end
    end

    context "when choosing an invalid person" do
      let(:chosen_person_ids) { [create(:person).id] }

      it "doesn't close the issue" do
        expect { subject }.not_to change { issue.reload.closed? } .from(false)
      end

      it "doesn't mark the issue as fixed" do
        expect { subject }.not_to change { issue.reload.close_result } .from(nil)
      end

      it "doesn't reassigns the phone of the already verified person" do
        expect { subject }.not_to change { already_verified_person.reload.phone_verification }
      end

      it "doesn't trashes the previously verified person" do
        expect { subject }.not_to change { previously_verified_person.reload.trashed? }
      end
    end
  end

  describe "#gone!" do
    subject(:gone) { issue.gone! }

    it "closes the issue" do
      expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
    end

    it "marks the issue as gone" do
      expect { subject }.to change { issue.reload.close_result } .from(nil).to("gone")
    end
  end
end
