# frozen_string_literal: true

module Issuable
  extend ActiveSupport::Concern

  included do
    has_many :issue_objects, as: :object
    has_many :issues, through: :issue_objects
  end
end
