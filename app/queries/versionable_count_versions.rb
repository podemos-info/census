# frozen_string_literal: true

class VersionableCountVersions < Rectify::Query
  def self.for(versionable)
    new(versionable).value
  end

  def initialize(versionable)
    @versionable = versionable
  end

  def query
    @versionable.versions
  end

  def value
    query.count
  end
end
