# frozen_string_literal: true

module Issues
  # A command to create unread marks for admins affected by an issue
  class CreateIssueUnreads < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to mark as unread
    def initialize(issue:)
      @issue = issue
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the issue unread mark couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:ok) unless issue.role
      result = Issue.transaction do
        admins.each do |admin|
          IssueUnread.create!(issue: issue, admin: admin)
        end
        :ok
      end
      broadcast(result || :invalid)
    end

    private

    attr_reader :issue

    def admins
      @admins ||= AdminsByRole.for(issue.role)
    end
  end
end
