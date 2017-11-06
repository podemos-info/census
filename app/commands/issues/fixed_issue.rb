# frozen_string_literal: true

module Issues
  # A command to mark an issue as fixed
  class FixedIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to assign
    # admin - The admin that has fixed the issue
    def initialize(issue:, admin:)
      @issue = issue
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if anything fails
    #
    # Returns nothing.
    def call
      result = Issue.transaction do
        issue.assigned_to ||= admin.person if admin
        issue.fixed_at = Time.now
        issue.save!

        issue_unreads.destroy_all
        :ok
      end
      broadcast(result || :invalid)
    end

    private

    attr_reader :issue, :admin

    def issue_unreads
      @issue_unreads ||= issue.issue_unreads
    end
  end
end
