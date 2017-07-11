# frozen_string_literal: true

require "rails_helper"

describe Attachment, :db do
  let(:attachment) { build(:attachment) }

  subject { attachment }

  it { is_expected.to be_valid }
end