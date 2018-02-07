# frozen_string_literal: true

class Event < ApplicationRecord
  include Ahoy::Properties

  belongs_to :visit, optional: true
  belongs_to :admin, optional: true

  alias_attribute :user, :admin
end
