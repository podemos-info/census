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
    # - :fixed_issue if the existing for the object issue was solved.
    #
    # Returns nothing.
    def call
      issuable.possible_issues&.each do |issue_type|
        check_issue(issue_type)
      end
    end

    private

    def check_issue(issue_type)
      issue = issue_type.for(issuable)
      return broadcast(:no_issue, issue_type: issue_type) if issue.absent?

      issue.fill
      result = Issue.transaction do
        ret = if issue.new_record?
                Issues::CreateIssueUnreads.call(issue: issue, admin: admin)
                :new_issue
              elsif issue.fixed?
                Issues::FixedIssue.call(issue: issue, admin: admin)
                :fixed_issue
              else
                :existing_issue
              end
        issue.save!
        ret
      end

      broadcast(result || :error, issue_type: issue_type, issue: issue)
    end

    attr_reader :issuable, :admin
  end
end
