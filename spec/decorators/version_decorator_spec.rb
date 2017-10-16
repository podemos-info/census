# frozen_string_literal: true

require "rails_helper"

describe VersionDecorator do
  subject(:decorator) { version.decorate }
  let(:version) { create(:version) }

  with_versioning do
    describe "#description" do
      subject(:method) { decorator.description }

      context "when is a creation" do
        let(:version) { create(:version, :creation) }

        it { is_expected.to eq("Creación de persona") }
      end

      context "when has one change" do
        it { is_expected.to eq("Actualización de nombre en persona") }
      end

      context "when has many changes" do
        let(:version) { create(:version, :many_changes) }

        it { is_expected.to eq("Actualización de 5 valores en persona") }
      end

      context "when is a deletion" do
        let(:version) { build(:version, :deletion) }

        it { is_expected.to eq("Borrado de persona") }
      end
    end
  end
end
