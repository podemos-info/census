# frozen_string_literal: true

# The issue unread model.
class IssueUnread < ApplicationRecord
  belongs_to :issue
  belongs_to :admin
end
