# frozen_string_literal: true

class AdminsByRole < Rectify::Query
  def self.for(role)
    new(role).query
  end

  def initialize(role)
    @role = role
  end

  def query
    Admin.where(role: @role)
  end
end
