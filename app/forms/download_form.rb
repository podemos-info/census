# frozen_string_literal: true

# The form object that handles the data for a download
class DownloadForm < Form
  include ::HasPerson

  mimic :download

  attribute :file, Hash
  attribute :expires_at, Date

  validates :file, :expires_at, presence: true

  def file=(value)
    super parse_uploaded_file value
  end
end
