# frozen_string_literal: true

# A base form object to hold common logic
class Form < Rectify::Form
  include Normalizr::Concern

  def parse_uploaded_file(file)
    tempfile = Tempfile.new("", uploaded_files_path)
    tempfile.binmode
    tempfile << (file[:content] || Base64.decode64(file[:base64_content]))
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(filename: file[:filename], type: file[:content_type], tempfile: tempfile)
  end

  def uploaded_files_path
    @uploaded_files_path ||= begin
      path = File.join(Rails.application.root.to_s, "tmp", "uploaded_files")
      ::FileUtils.mkdir_p(path)
      path
    end
  end
end
