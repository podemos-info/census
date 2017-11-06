# frozen_string_literal: true

require "rails_helper"

describe Issues::CheckProcessedOrderIssues do
  subject(:command) { described_class.call(order: order, admin: admin) }

  let(:order) { create(:order) }
  let(:admin) { create(:admin) }

  describe "when the order is not processed" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end
    it "doesn't create new issues" do
      expect { subject } .not_to change { Issue.count }
    end
  end

  describe "when the order was correctly processed" do
    let(:order) { create(:order, :external_verified, :processed) }
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end
    it "doesn't create new issues" do
      expect { subject } .not_to change { Issue.count }
    end
  end

  describe "when the order has been processed with errors" do
    let(:order) { create(:order, :external_verified, :processed, :user_issue) }

    it "broadcast :new_issue" do
      expect { subject } .to broadcast(:new_issue)
    end
    it "creates a new issue" do
      expect { subject } .to change { Issue.count } .by(1)
    end

    context "the created issue" do
      subject(:issue) { Issue.last }
      before { command }

      it "is related to the order" do
        expect(issue.orders).to contain_exactly(order)
      end
      it "is related to the order's payment method" do
        expect(issue.payment_methods).to contain_exactly(order.payment_method)
      end
      it "is assigned to the user" do
        expect(issue.assigned_to).to eq(order.person)
      end

      context "is for finances" do
        let(:order) { create(:order, :external_verified, :processed, :finances_issue) }
        it { is_expected.to be_finances_role }
      end

      context "is for system users" do
        let(:order) { create(:order, :external_verified, :processed, :system_issue) }
        it { is_expected.to be_system_role }
      end
    end

    context "with a new credit card payment method" do
      let(:order) { create(:order, :external, :processed, :user_issue) }

      it "broadcast :ok" do
        expect { subject } .to broadcast(:ok)
      end
      it "does not create a new issue" do
        expect { subject } .not_to change { Issue.count }
      end
    end
  end
end
