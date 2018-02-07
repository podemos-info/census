# frozen_string_literal: true

module Issues
  # An abstract command to create, update or fix issues for an object
  class CheckIssues < Rectify::Command
    # Executes the command. Broadcasts these events:
    #
    # - :ok when there were no issues with the object.
    # - :error if the issue couldn't be updated.
    # - :new_issue if there is a new issue with the object.
    # - :existing_issue if there already was a non fixed issue with the object.
    # - :fixed_issue if the existing for the object issue was solved.
    #
    # Returns nothing.
    def call
      return broadcast(:ok) if !has_issue? && issue.new_record?

      result = Issue.transaction do
        if issue.new_record?
          current_issue = :new_issue
          issue.save!
          Issues::CreateIssueUnreads.call(issue: issue, admin: admin)
        elsif has_issue?
          current_issue = :existing_issue
        else
          current_issue = :fixed_issue
          Issues::FixedIssue.call(issue: issue, admin: admin)
        end
        update_affected_objects
        current_issue
      end

      broadcast(result || :error, issue: issue)
    end

    attr_reader :admin
  end
end
