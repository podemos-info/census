# frozen_string_literal: true

module Issues
  # A command to close an issue
  class CloseIssue < Rectify::Command
    # Public: Initializes the command.
    #
    # issue - The issue to close
    # admin - The admin that has fixed the issue
    def initialize(issue:, admin: nil)
      @issue = issue
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when given data is invalid.
    # - :error if the issue couldn't be saved as closed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless issue

      result = close
      broadcast result

      post_close if result == :ok
    end

    protected

    attr_reader :issue, :action, :admin

    def issue_unreads
      @issue_unreads ||= issue.issue_unreads
    end

    def close
      ret = :error
      Issue.transaction do
        if close_action
          issue.assigned_to ||= admin&.person
          issue_unreads.destroy_all
          ret = :ok
        else
          ret = :invalid
          raise ActiveRecord::Rollback
        end
      end
      ret
    end

    def post_close
      issue.post_close(admin)
    end
  end
end
