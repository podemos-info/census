# frozen_string_literal: true

require "rails_helper"
require "census/seeds/scopes"

describe Census::Seeds::Scopes do
  describe "#seed" do
    subject(:method) { described_class.seed base_path: base_path }
    let(:base_path) { File.expand_path("../../../factories/seeds", __dir__) }

    it "load scopes data" do
      expect { subject } .to change { Scope.count } .from(0)
    end

    it "load scope types data" do
      expect { subject } .to change { ScopeType.count } .from(0)
    end
  end
end
