# frozen_string_literal: true

class Admin < ApplicationRecord
  include HasRole
  include Discard::Model

  has_paper_trail class_name: "Version"
  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item

  has_many :jobs, dependent: :restrict_with_exception, foreign_key: "user_id"

  devise :database_authenticatable, :timeoutable, :lockable

  has_many :visits, dependent: :destroy
  has_many :events, dependent: :destroy

  belongs_to :person

  has_many :issue_unreads, dependent: :restrict_with_exception
  has_many :unread_issues, through: :issue_unreads, foreign_key: "issue_id", class_name: "Issue"
end
