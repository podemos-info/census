# frozen_string_literal: true

require "rails_helper"

describe "Admins", type: :request do
  include_context "devise login"

  subject(:page) { get admins_path }
  let!(:admin) { create(:admin) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "admin visits page" do
    let!(:visit) { create(:visit, admin: admin) }
    subject { get admin_visits_path(admin_id: admin.id) }
    it { expect(subject).to eq(200) }
  end

  with_versioning do
    context "show page" do
      subject(:page) { get admin_path(id: admin.id) }
      it { is_expected.to eq(200) }
    end

    context "admin versions page" do
      before do
        admin.update! username: "#{admin.username}A" # create an admin version
      end
      subject { get admin_versions_path(admin_id: admin.id) }
      it { expect(subject).to eq(200) }
    end
  end
end
