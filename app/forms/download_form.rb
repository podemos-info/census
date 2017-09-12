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
    super(begin
            tempfile = Tempfile.new("")
            tempfile.binmode
            tempfile << Base64.decode64(value[:base64_content])
            tempfile.rewind
            ActionDispatch::Http::UploadedFile.new(filename: value[:filename], type: value[:content_type], tempfile: tempfile)
          end)
  end
end
