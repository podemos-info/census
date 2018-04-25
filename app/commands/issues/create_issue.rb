# frozen_string_literal: true

module Issues
  # A command to create an issue and unread marks for admins affected by an issue
  class CreateIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to mark as unread
    # admin - The admin that is creating the issue
    def initialize(issue:, admin: nil)
      @issue = issue
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when given data is invalid.
    # - :error if the issue unread mark couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless issue
      return broadcast(:ok) unless issue.role

      result = Issue.transaction do
        issue.save!
        admins.each do |admin|
          IssueUnread.create!(issue: issue, admin: admin)
        end
        :ok
      end
      broadcast(result || :error)
    end

    private

    attr_reader :issue

    def admins
      @admins ||= AdminsByRole.for(issue.role)
    end
  end
end
