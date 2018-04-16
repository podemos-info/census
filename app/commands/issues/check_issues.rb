# frozen_string_literal: true

module Issues
  # An abstract command to create, update or fix issues for an object
  class CheckIssues < Rectify::Command
    # Public: Initializes the command.
    #
    # issuable - The issuable object to check
    # admin - The admin user triggered the check.
    def initialize(issuable:, admin:)
      @issuable = issuable
      @admin = admin
    end

    # Executes the command. Broadcasts one of these events for each type of issue
    # related to the issuable object:
    #
    # - :no_issue when there were no issues with the object.
    # - :error if the issue information couldn't be saved.
    # - :new_issue if there is a new issue with the object.
    # - :existing_issue if there already was a non fixed issue with the object.
    # - :gone_issue if the issue exists but the problem is not detected anymore.
    #
    # Returns nothing.
    def call
      issuable.possible_issues&.each do |issue_type|
        check_issue(issue_type)
      end
    end

    private

    attr_reader :issuable, :admin

    def check_issue(issue_type)
      issue = issue_type.for(issuable)
      return broadcast(:no_issue, issue_type: issue_type) if issue.absent?

      issue.fill
      result = Issue.transaction do
        ret = check_issue_state(issue)
        issue.save! unless [:invalid, :error].include?(ret)
        ret
      end

      broadcast(result || :error, issue_type: issue_type, issue: issue)
    end

    def check_issue_state(issue)
      if issue.new_record?
        create issue
      elsif !issue.closed? && !issue.detected?
        gone issue
      else
        :existing_issue
      end
    end

    def create(issue)
      ret = :error
      Issues::CreateIssueUnreads.call(issue: issue, admin: admin) do
        on(:invalid) { ret = :invalid }
        on(:error) {}
        on(:ok) { ret = :new_issue }
      end
      ret
    end

    def gone(issue)
      ret = :error
      Issues::GoneIssue.call(issue: issue, admin: admin) do
        on(:invalid) { ret = :invalid }
        on(:error) {}
        on(:ok) { ret = :gone_issue }
      end
      ret
    end
  end
end
