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
    # - :ok when everything was ok.
    # - :invalid when given data is invalid.
    # - :error if the assignment couldn't be saved.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless issue && admin

      result = Issue.transaction do
        issue.assigned_to = admin.person
        issue.save!
        :ok
      end
      broadcast(result || :error)
    end

    private

    attr_reader :issue, :admin
  end
end
