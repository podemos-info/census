# frozen_string_literal: true

require "rails_helper"

describe Scope, :db do
  let(:scope) { build(:scope) }

  subject { scope }

  it { is_expected.to be_valid }
end
