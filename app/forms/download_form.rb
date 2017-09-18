# frozen_string_literal: true

# The form object that handles the data for a download
class DownloadForm < Form
  mimic :download

  attribute :person_id, Integer
  attribute :file, Hash
  attribute :expires_at, Date

  validates :person_id, :file, :expires_at, presence: true

  def person
    Person.find(person_id)
  end

  def file=(value)
    super parse_uploaded_file value
  end
end
