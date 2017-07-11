# frozen_string_literal: true

require "rails_helper"

describe ScopeType, :db do
  let(:scope_type) { build(:scope_type) }

  subject { scope_type }

  it { is_expected.to be_valid }
end
