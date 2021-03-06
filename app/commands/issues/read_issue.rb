# frozen_string_literal: true

module Issues
  # A command to remove unread mark for an issue and an admin
  class ReadIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to mark as read
    # admin - The admin that has read the issue
    def initialize(issue:, admin:)
      @issue = issue
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when given data is invalid.
    # - :error if the issue couldn't be set as read.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless valid?
      return broadcast(:ok) unless issue_unread

      broadcast read || :error
    end

    private

    attr_reader :issue, :admin

    def valid?
      issue && admin
    end

    def issue_unread
      @issue_unread ||= IssueUnread.find_by(admin: admin, issue: issue)
    end

    def read
      Issue.transaction do
        issue_unread.destroy!
        :ok
      end
    end
  end
end
