# frozen_string_literal: true

require "rails_helper"

describe Issues::People::AdminRemark, :db do
  subject(:issue) { create(:admin_remark) }

  let(:procedure_person) { issue.procedure.person }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }

    let(:issue) { create(:admin_remark, :not_evaluated) }

    it "stores the affected people array" do
      expect { subject }.to change { issue.people.to_a }.from([]).to([procedure_person])
    end
  end

  describe "#detected?" do
    it "returns true" do
      is_expected.to be_detected
    end

    context "when person is trashed" do
      before { procedure_person.trash }

      it "returns false" do
        is_expected.not_to be_detected
      end
    end
  end

  describe "#fix!" do
    subject(:fix) do
      issue.fixed = fixed
      issue.comment = comment
      issue.fix!
    end

    let(:comment) { Faker::Lorem.paragraph(1, true, 2) }

    context "when marks issue as fixed" do
      let(:fixed) { true }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "is fixed for the procedure person" do
        expect { subject }.to change { issue.fixed_for?(procedure_person) }.from(false).to(true)
      end
    end

    context "when marks issue as not fixed" do
      let(:fixed) { false }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as not fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("not_fixed")
      end

      it "is not fixed for the procedure person" do
        expect { subject }.not_to change { issue.fixed_for?(procedure_person) }.from(false)
      end
    end
  end
end
