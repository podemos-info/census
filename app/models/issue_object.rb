# frozen_string_literal: true

# The issue object model.
class IssueObject < ApplicationRecord
  belongs_to :issue
  belongs_to :object, polymorphic: true
end
