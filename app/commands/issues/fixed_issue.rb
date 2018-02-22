# frozen_string_literal: true

module Issues
  # A command to mark an issue as fixed
  class FixedIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to assign
    # admin - The admin that has fixed the issue
    def initialize(issue:, admin: nil)
      @issue = issue
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when given data is invalid.
    # - :error if the issue couldn't be set as fixed and read.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless issue

      broadcast fix || :error
    end

    private

    attr_reader :issue, :admin

    def issue_unreads
      @issue_unreads ||= issue.issue_unreads
    end

    def fix
      Issue.transaction do
        issue.assigned_to ||= admin.person if admin
        issue.fixed_at = Time.zone.now
        issue.save!
        issue_unreads.destroy_all
        :ok
      end
    end
  end
end
