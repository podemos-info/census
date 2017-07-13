# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  let(:procedure) { build(:verification_document) }

  subject { procedure }

  it { is_expected.to be_valid }
end
