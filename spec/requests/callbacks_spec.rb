# frozen_string_literal: true

require "rails_helper"

describe "Callbacks", type: :request do
  let(:person) { build(:person) }

  context "payments method" do
    subject { post callbacks_payments_path(:redsys) }

    it "ignore invalid request" do
      expect(subject).to eq(204)
    end

    include_examples "only authorized payment callbacks"
  end
end
