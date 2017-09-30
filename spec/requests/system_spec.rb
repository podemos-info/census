# frozen_string_literal: true

require "rails_helper"

describe "System", type: :request do
  include_context "devise login"

  context "index page" do
    subject { get system_path }
    it { expect(subject).to eq(200) }
  end
end
