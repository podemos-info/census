# frozen_string_literal: true

module Issues
  # A command to mark an issue as gone
  class GoneIssue < CloseIssue
    def close_action
      issue.gone!
    end
  end
end
