# frozen_string_literal: true

class PersonLocation < ApplicationRecord
  include Discard::Model

  belongs_to :person
end
