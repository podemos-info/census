# frozen_string_literal: true

shared_context "when slave mode" do
  before { Settings.system.slave_mode = true }

  after { Settings.system.slave_mode = false }
end

shared_examples_for "a policy that forbids data modifications on slave mode" do
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

shared_examples_for "an API endpoint that forbids modifications on slave mode" do
  include_context "when slave mode"

  it { is_expected.to have_http_status(:conflict) }
end

shared_examples_for "an admin page that forbids modifications on slave mode" do
  include_context "when slave mode"

  it { is_expected.to have_http_status(:found) }
  it { expect { subject } .to change { flash[:error] } .from(nil).to("No está autorizado/a a realizar esta acción.") }
end
