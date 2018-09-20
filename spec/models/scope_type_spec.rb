# frozen_string_literal: true

require "rails_helper"

describe ScopeType, :db do
  subject { scope_type }

  let(:scope_type) { build(:scope_type) }

  it { is_expected.to be_valid }
end
