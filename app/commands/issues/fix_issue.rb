# frozen_string_literal: true

module Issues
  # A command to fix an issue
  class FixIssue < CloseIssue
    def close_action
      issue.fix!
    end
  end
end
