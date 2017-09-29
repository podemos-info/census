# frozen_string_literal: true

require "rails_helper"

describe VersionDecorator do
  subject(:decorator) { version.decorate }
  let(:version) { create(:version) }

  with_versioning do
    context "#description" do
      subject(:method) { decorator.description }
      let(:version) { create(:version, :many_changes) }

      it "returns the scope path" do
        is_expected.to eq("Actualización de 5 valores en persona")
      end
    end
  end
end
