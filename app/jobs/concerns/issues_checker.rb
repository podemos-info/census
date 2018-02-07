# frozen_string_literal: true

module IssuesChecker
  extend ActiveSupport::Concern

  included do
    def log_issues_message
      @log_issues_message ||= proc {
        on(:ok) { log :user, key: "issues_job.ok" }
        on(:new_issue) { |info| log :user, key: "issues_job.new_issue", related: [info[:issue].to_gid_param] }
        on(:existing_issue) { |info| log :user, key: "issues_job.existing_issue", related: [info[:issue].to_gid_param] }
        on(:fixed_issue) { |info| log :user, key: "issues_job.fixed_issue", related: [info[:issue].to_gid_param] }
        on(:error) { |info| log :user, key: "issues_job.error", related: [info[:issue]&.to_gid_param] }
      }
    end
  end
end
