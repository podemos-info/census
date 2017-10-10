# frozen_string_literal: true

require "rails_helper"

describe Payments::Processors::Redsys do
  subject(:processor) { described_class.new }
end
