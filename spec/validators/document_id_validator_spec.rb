# frozen_string_literal: true

require "rails_helper"

describe DocumentIdValidator do
  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :document_id
      attribute :document_type
      attribute :document_scope

      validates :document_id, document_id: { type: :document_type, scope: :document_scope }
    end
  end

  let(:subject) { validatable.new(document_type: document_type, document_scope: document_scope, document_id: document_id) }

  context "with a spanish document" do
    let(:document_scope) { "ES" }

    context "with a DNI" do
      let(:document_type) { :dni }
      let(:document_id) { "00000001R" }

      it { is_expected.to be_valid }

      context "when the id is not upcased" do
        let(:document_id) { "00000001r" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too short" do
        let(:document_id) { "1R" }

        it { is_expected.to be_invalid }
      end

      context "when the id format is wrong" do
        let(:document_id) { "ABCD12345" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too long" do
        let(:document_id) { "000000001R" }

        it { is_expected.to be_invalid }
      end

      context "when the final letter is wrong" do
        let(:document_id) { "00000001T" }

        it { is_expected.to be_invalid }
      end
    end

    context "with a NIE" do
      let(:document_type) { :nie }
      let(:document_id) { "X0000001R" }

      it { is_expected.to be_valid }

      context "when the id is not upcased" do
        let(:document_id) { "x0000001r" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too short" do
        let(:document_id) { "X1R" }

        it { is_expected.to be_invalid }
      end

      context "when the id format is wrong" do
        let(:document_id) { "ABCD12345" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too long" do
        let(:document_id) { "0X0000001R" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too long" do
        let(:document_id) { "0X0000001R" }

        it { is_expected.to be_invalid }
      end

      context "when the final letter is wrong" do
        let(:document_id) { "X0000001T" }

        it { is_expected.to be_invalid }
      end
    end

    context "with a passport" do
      let(:document_type) { :passport }
      let(:document_id) { "ABC123456" }

      it { is_expected.to be_valid }

      context "when is not upcased" do
        let(:document_id) { "abc123456" }

        it { is_expected.to be_invalid }
      end

      context "when has the old format" do
        let(:document_id) { "AB123456" }

        it { is_expected.to be_valid }
      end

      context "when has the very old format, based on DNI number" do
        let(:document_id) { "A0000000100" }

        it { is_expected.to be_valid }
      end

      context "when the id format is wrong" do
        let(:document_id) { "123456ABC" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too short" do
        let(:document_id) { "1234" }

        it { is_expected.to be_invalid }
      end

      context "when the id is too long" do
        let(:document_id) { "0A000000100" }

        it { is_expected.to be_invalid }
      end
    end
  end

  context "with a non spanish passport" do
    let(:document_type) { :passport }
    let(:document_scope) { "EU" }
    let(:document_id) { "AB123456" }

    it { is_expected.to be_valid }

    context "when the id is too short" do
      let(:document_id) { "123" }

      it { is_expected.to be_invalid }
    end
  end
end
