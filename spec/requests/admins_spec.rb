# frozen_string_literal: true

require "rails_helper"

describe "Admins", type: :request do
  include_context "devise login"

  subject(:page) { get admins_path }
  let!(:admin) { create(:admin) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get admin_path(id: admin.id) }
    it { is_expected.to eq(200) }
  end
end
