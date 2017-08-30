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

  context "when the scope is Spain" do
    let(:document_scope) { "ES" }

    context "and the document type is DNI" do
      let(:document_type) { :dni }
      let(:document_id) { "00000001R" }

      it { is_expected.to be_valid }

      context "fails if is not upcased" do
        let(:document_id) { "00000001r" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too short" do
        let(:document_id) { "1R" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id format is wrong" do
        let(:document_id) { "ABCD12345" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too long" do
        let(:document_id) { "000000001R" }
        it { is_expected.to be_invalid }
      end

      context "fails if the final letter is wrong" do
        let(:document_id) { "00000001T" }
        it { is_expected.to be_invalid }
      end
    end

    context "and the document type is NIE" do
      let(:document_type) { :nie }
      let(:document_id) { "X0000001R" }

      it { is_expected.to be_valid }

      context "fails if is not upcased" do
        let(:document_id) { "x0000001r" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too short" do
        let(:document_id) { "X1R" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id format is wrong" do
        let(:document_id) { "ABCD12345" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too long" do
        let(:document_id) { "0X0000001R" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too long" do
        let(:document_id) { "0X0000001R" }
        it { is_expected.to be_invalid }
      end

      context "fails if the final letter is wrong" do
        let(:document_id) { "X0000001T" }
        it { is_expected.to be_invalid }
      end
    end

    context "and the document type is Passport" do
      let(:document_type) { :passport }
      let(:document_id) { "ABC123456" }

      it { is_expected.to be_valid }

      context "fails if is not upcased" do
        let(:document_id) { "abc123456" }
        it { is_expected.to be_invalid }
      end

      context "accepts old format" do
        let(:document_id) { "AB123456" }
        it { is_expected.to be_valid }
      end

      context "accepts very old format, based on DNI number" do
        let(:document_id) { "A0000000100" }
        it { is_expected.to be_valid }
      end

      context "fails if the id format is wrong" do
        let(:document_id) { "123456ABC" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too short" do
        let(:document_id) { "1234" }
        it { is_expected.to be_invalid }
      end

      context "fails if the id is too long" do
        let(:document_id) { "0A000000100" }
        it { is_expected.to be_invalid }
      end
    end
  end

  context "when the scope is not Spain" do
    let(:document_scope) { "EU" }

    context "and the document type is DNI" do
      let(:document_type) { :dni }
      let(:document_id) { "00000001R" }

      it { is_expected.to be_valid }

      context "fails if the id is too short" do
        let(:document_id) { "1R" }
        it { is_expected.to be_invalid }
      end
    end

    context "and the document type is NIE" do
      let(:document_type) { :nie }
      let(:document_id) { "X0000001R" }

      it { is_expected.to be_valid }

      context "fails if the id is too short" do
        let(:document_id) { "X1R" }
        it { is_expected.to be_invalid }
      end
    end

    context "and the document type is Passport" do
      let(:document_type) { :nie }
      let(:document_id) { "ABC123456" }

      it { is_expected.to be_valid }

      context "accepts any format" do
        let(:document_id) { "AB123456" }
        it { is_expected.to be_valid }
      end

      context "fails if the id is too short" do
        let(:document_id) { "123" }
        it { is_expected.to be_invalid }
      end
    end
  end
end
