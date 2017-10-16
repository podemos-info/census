# frozen_string_literal: true

require "rails_helper"

describe PaymentMethods::DirectDebit, :db do
  subject(:direct_debit) { build(:direct_debit) }

  it { is_expected.to be_valid }

  describe "#reprocessable?" do
    it { is_expected.to be_reprocessable }
  end
end
