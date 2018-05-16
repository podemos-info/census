# frozen_string_literal: true

require "rails_helper"
require "census/seeds/scopes"

describe Census::Seeds::Scopes do
  describe "#seed" do
    subject(:method) { described_class.seed base_path: base_path }
    before { FileUtils.rm_rf(Census::Seeds::Scopes::CACHE_PATH) }

    let(:base_path) { File.expand_path("../../../factories/seeds", __dir__) }
    let(:instance) { described_class.instance_variable_get("@instance") }

    it "loads scopes data" do
      expect { subject } .to change { Scope.count } .from(0).to(20)
    end

    it "loads scope types data" do
      expect { subject } .to change { ScopeType.count } .from(0).to(7)
    end

    it "loads scope data from files" do
      expect(instance).to receive(:save_scope).at_least(1)
      subject
    end

    context "when data is cached" do
      before do
        described_class.seed base_path: base_path
        described_class.cache_scopes
        Scope.delete_all
      end

      it "load cached scopes data" do
        expect { subject } .to change { Scope.count } .from(0).to(20)
      end

      it "doesn't load scope data from files" do
        expect(instance).not_to receive(:save_scope)
        subject
      end
    end
  end
end
