# frozen_string_literal: true

require "rails_helper"

describe Issues::Payments::MissingBic, :db do
  subject(:issue) { create(:missing_bic) }

  it { is_expected.to be_valid }

  describe "#fill" do
    subject(:fill) { issue.fill }

    let(:issue) { create(:missing_bic, :not_evaluated, issuable: order.payment_method) }
    let(:order) { create(:order) }

    it "stores the affected payment method" do
      expect { subject }.to change { issue.payment_methods.to_a }.from([]).to([order.payment_method])
    end

    it "stores the affected order" do
      expect { subject }.to change { issue.orders.to_a }.from([]).to([order])
    end
  end

  describe "#fix!" do
    subject(:fix) do
      issue.bic = bic
      issue.fix!
    end

    let(:country) { issue.country }
    let(:bank_code) { issue.bank_code }

    context "when setting a valid bic" do
      let(:bic) { "ABCD#{country}XX" }

      it "closes the issue" do
        expect { subject }.to change { issue.reload.closed? } .from(false).to(true)
      end

      it "marks the issue as fixed" do
        expect { subject }.to change { issue.reload.close_result } .from(nil).to("fixed")
      end

      it "creates a new bic record" do
        expect { subject }.to change { Bic.where(country: country, bank_code: bank_code).count }.from(0).to(1)
      end
    end

    context "when setting an invalid bic" do
      let(:bic) { "POTATO" }

      it "doesn't close the issue" do
        expect { subject }.not_to change { issue.reload.closed? } .from(false)
      end

      it "doesn't mark the issue as fixed" do
        expect { subject }.not_to change { issue.reload.close_result } .from(nil)
      end

      it "doesn't create a new bic record" do
        expect { subject }.not_to change { Bic.where(country: country, bank_code: bank_code).count }.from(0)
      end
    end
  end
end
