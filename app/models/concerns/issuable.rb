# frozen_string_literal: true

module Issuable
  extend ActiveSupport::Concern

  included do
    has_many :issue_objects, as: :object
    has_many :issues, -> { distinct }, through: :issue_objects

    def possible_issues; end
  end

  def has_issues?
    issues.any?
  end
end
