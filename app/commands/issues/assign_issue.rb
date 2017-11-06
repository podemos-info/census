# frozen_string_literal: true

module Issues
  # A command to assign an issue to an admin
  class AssignIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to assign
    # admin - The admin to be assigned
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
        issue.assigned_to = admin.person
        issue.save!
        :ok
      end
      broadcast(result || :invalid)
    end

    private

    attr_reader :issue, :admin
  end
end
