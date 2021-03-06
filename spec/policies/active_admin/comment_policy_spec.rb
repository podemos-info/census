# frozen_string_literal: true

require "rails_helper"

describe ActiveAdmin::CommentPolicy do
  subject(:policy) { described_class.new(user, comment) }

  let(:comment) { instance_double(ActiveAdmin::Comment) }

  context "when user is a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_actions [:new, :create, :show, :index] }
    it { is_expected.to forbid_actions [:edit, :update, :destroy] }
  end

  context "when user is a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to permit_actions [:new, :create, :show, :index] }
    it { is_expected.to forbid_actions [:edit, :update, :destroy] }
  end

  context "when user is a data_help admin" do
    let(:user) { create(:admin, :data_help) }

    it { is_expected.to permit_actions [:new, :create, :show, :index] }
    it { is_expected.to forbid_actions [:edit, :update, :destroy] }
  end

  context "when user is a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_actions [:new, :create, :show, :index] }
    it { is_expected.to forbid_actions [:edit, :update, :destroy] }
  end

  it_behaves_like "a policy that forbids data modifications on slave mode"
end
