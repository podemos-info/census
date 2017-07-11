# frozen_string_literal: true

require "rails_helper"

describe PersonDecorator do
  let(:person) { build(:person) }
  subject { PersonDecorator.new(person) }

end
