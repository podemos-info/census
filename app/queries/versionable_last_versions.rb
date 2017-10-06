# frozen_string_literal: true

class VersionableLastVersions < Rectify::Query
  def self.for(versionable)
    new(versionable).query
  end

  def initialize(versionable)
    @versionable = versionable
  end

  def query
    @versionable.versions.reorder(created_at: :desc).limit(3)
  end
end
