# frozen_string_literal: true

class Admin < ApplicationRecord
  acts_as_paranoid
  has_paper_trail class_name: "Version"
  has_many :versions, as: :item

  devise :database_authenticatable, :timeoutable, :lockable

  has_many :visits
  has_many :events

  belongs_to :person

  enum role: [:system, :lopd, :lopd_help, :finances], _suffix: true
end
