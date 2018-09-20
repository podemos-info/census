# frozen_string_literal: true

require "rails_helper"

describe "Admins", type: :request do
  include_context "devise login"

  subject(:page) { get admins_path }

  let(:admin) { create(:admin) }

  describe "index page" do
    it { is_expected.to eq(200) }
  end

  describe "admin visits page" do
    subject { get admin_visits_path(admin_id: admin.id) }

    before { visit }

    let(:visit) { create(:visit, admin: admin) }

    it { expect(subject).to eq(200) }
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get admin_path(id: admin.id) }

      it { is_expected.to eq(200) }
    end

    describe "admin versions page" do
      subject { get admin_versions_path(admin_id: admin.id) }

      before do
        admin.update! username: "#{admin.username}A" # create an admin version
      end

      it { expect(subject).to eq(200) }
    end
  end
end
