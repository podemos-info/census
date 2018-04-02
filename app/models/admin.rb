# frozen_string_literal: true

class Admin < ApplicationRecord
  include HasRole
  include Discard::Model

  has_paper_trail class_name: "Version"
  has_many :versions, as: :item

  has_many :jobs, foreign_key: "user_id"

  devise :database_authenticatable, :timeoutable, :lockable

  has_many :visits
  has_many :events

  belongs_to :person

  has_many :issue_unreads
  has_many :unread_issues, through: :issue_unreads, foreign_key: "issue_id", class_name: "Issue"
end
