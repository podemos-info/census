# frozen_string_literal: true

module Issuable
  extend ActiveSupport::Concern

  included do
    has_many :issue_objects, as: :object, dependent: :destroy, inverse_of: :object
    has_many :issues, -> { distinct }, through: :issue_objects

    has_many :open_issues, -> { merge(IssuesOpen.for).distinct }, through: :issue_objects, source: :issue, class_name: "Issue"

    scope :with_open_issues, -> { joins(:open_issues).distinct }
    scope :without_open_issues, -> { where.not(id: with_open_issues.reorder(nil)) }

    def possible_issues; end
  end
end
