# frozen_string_literal: true

require "rails_helper"

describe DashboardController, type: :controller do
  render_views

  describe "index page" do
    subject { get :index }

    context "with devise authentication" do
      include_context "with a devise login"

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "tracks the user visit"
    end

    context "with CAS authentication" do
      include_context "with a CAS login"

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "tracks the user visit"
    end
  end
end
