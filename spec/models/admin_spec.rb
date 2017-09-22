# frozen_string_literal: true

require "rails_helper"

describe Admin, :db do
  subject(:admin) { build(:admin) }

  it { is_expected.to be_valid }
end
