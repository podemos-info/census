# frozen_string_literal: true

require "rails_helper"

describe FactoryBot do
  subject { described_class.lint }

  it { is_expected.to be_nil }
end
