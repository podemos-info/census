# frozen_string_literal: true

class PersonLastActiveDownloads < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.downloads.where("expires_at > ?", DateTime.now).order(created_at: :desc).limit(3)
  end
end
