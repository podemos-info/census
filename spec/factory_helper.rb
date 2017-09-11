# frozen_string_literal: true

def test_file(filename, content_type)
  Rack::Test::UploadedFile.new(File.expand_path(File.join(__dir__, "factories", "files", filename)), content_type)
end
