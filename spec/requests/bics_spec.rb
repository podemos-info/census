# frozen_string_literal: true

require "rails_helper"

describe "Bics", type: :request do
  include_context "devise login"
  let!(:bic) { create(:bic) }

  context "index page" do
    subject(:page) { get bics_path(params) }
    let(:params) { {} }
    it { expect(subject).to eq(200) }
  end

  context "new page" do
    subject { get new_bic_path }
    it { expect(subject).to eq(200) }
  end

  context "edit page" do
    subject { get edit_bic_path(id: bic.id) }
    it { expect(subject).to eq(200) }
  end
end
