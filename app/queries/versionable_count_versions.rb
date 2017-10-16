# frozen_string_literal: true

class VersionableCountVersions < Rectify::Query
  def self.for(versionable)
    new(versionable).value
  end

  def initialize(versionable)
    @versionable = versionable
  end

  def query
    @versionable.versions.where(event: "update")
  end

  def value
    query.count + 1
  end
end
