# frozen_string_literal: true

class Visit < ActiveRecord::Base
  has_many :events

  belongs_to :admin, optional: true

  alias_attribute :user, :admin
end
