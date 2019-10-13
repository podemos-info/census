# frozen_string_literal: true

module ApiHelper
  def api_attachment_format(attachment)
    {
      filename: File.basename(attachment.file.path),
      content_type: attachment.content_type,
      base64_content: Base64.encode64(attachment.file.file.read)
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :controller
end
