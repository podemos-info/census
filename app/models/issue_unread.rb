# frozen_string_literal: true

class IssueUnread < ApplicationRecord
  belongs_to :issue
  belongs_to :admin
end
