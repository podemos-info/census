# frozen_string_literal: true

class ProceduresNotProcessedByType < Rectify::Query
  def self.for(type)
    new(type).query
  end

  def initialize(type)
    @type = type
  end

  def query
    @type.where(state: [:pending, :issues])
  end
end
