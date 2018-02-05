# frozen_string_literal: true

class IssueObject < ApplicationRecord
  belongs_to :issue
  belongs_to :object, polymorphic: true
end
