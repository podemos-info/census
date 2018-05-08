# frozen_string_literal: true

require "rails_helper"

describe Issues::People::UntrustedEmail, :db do
  subject(:issue) { create(:untrusted_email) }
  let(:procedure_person) { issue.procedure.person }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }
    let(:issue) { create(:untrusted_email, :not_evaluated) }

    it "stores the affected people array" do
      expect { subject }.to change { issue.people.to_a }.from([]).to([procedure_person])
    end
  end

  describe "#fix!" do
    subject(:fix) do
      issue.trusted = trusted
      issue.fix!
    end

    context "when marks email as trusted" do
      let(:trusted) { true }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "is fixed for the procedure person" do
        expect { subject }.to change { issue.fixed_for?(procedure_person) }.from(false).to(true)
      end
      include_context "hutch notifications"
    end

    context "when marks email as not trusted" do
      let(:trusted) { false }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "is not fixed for the procedure person" do
        expect { subject }.not_to change { issue.fixed_for?(procedure_person) }.from(false)
      end

      let(:publish_notification) do
        {
          routing_key: "census.people.full_status_changed",
          parameters: { person: procedure_person.qualified_id }
        }
      end
      include_context "hutch notifications"
    end

    context "when affected person is enabled and marks email as not trusted" do
      let(:issue) { create(:untrusted_email, :enabled_person) }
      let(:trusted) { false }

      it "trashes the existing person" do
        expect { subject }.to change { procedure_person.reload.trashed? }.from(false).to(true)
      end
    end
  end
end
