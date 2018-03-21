# frozen_string_literal: true

module Issuable
  extend ActiveSupport::Concern

  included do
    has_many :issue_objects, as: :object
    has_many :issues, -> { distinct }, through: :issue_objects

    def possible_issues; end
  end

  def issues_summary
    @issues_summary ||= begin
      ret = :ok
      issues.each do |issue|
        if issue.open?
          ret = :pending
        elsif !issue.fixed_for?(self)
          ret = :unrecoverable
          break
        end
      end
      ret
    end
  end
end
