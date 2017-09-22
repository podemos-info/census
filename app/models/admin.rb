# frozen_string_literal: true

class Admin < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  devise :database_authenticatable, :timeoutable, :lockable, :trackable

  belongs_to :person
end
