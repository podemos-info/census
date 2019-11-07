# frozen_string_literal: true

shared_context "when slave mode" do
  before { Settings.system.slave_mode = true }

  after { Settings.system.slave_mode = false }
end

shared_examples_for "a policy that forbits data modifications on slave mode" do
  include_context "when slave mode"

  let(:extra_actions) { [] }

  [:system, :data, :data_help, :finances].each do |role|
    context "when user is a system #{role}" do
      let(:user) { create(:admin, role) }

      it { is_expected.to forbid_actions [:new, :create, :edit, :update, :destroy] }
      it { is_expected.to(forbid_actions(extra_actions)) if extra_actions.any? }
    end
  end
end
