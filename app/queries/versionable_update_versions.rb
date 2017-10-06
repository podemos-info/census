# frozen_string_literal: true

class VersionableUpdateVersions < Rectify::Query
  def self.for(versionable)
    new(versionable).query
  end

  def initialize(versionable)
    @versionable = versionable
  end

  def query
    @versionable.versions.where(event: "update")
  end
end
