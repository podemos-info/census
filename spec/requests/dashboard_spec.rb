# frozen_string_literal: true

require "rails_helper"

describe "Dashboard", type: :request do
  include_context "with a devise login"

  describe "index page" do
    subject { get root_path }

    it { expect(subject).to eq(200) }
  end
end
