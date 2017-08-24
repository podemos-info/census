# frozen_string_literal: true

require "shared/only_authorized_clients"

require "simplecov"
SimpleCov.start

require "codecov"
SimpleCov.formatter = SimpleCov::Formatter::Codecov

# Only useful for request tests
def use_ip(ip)
  allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return(ip)
end

# hash with file data that will be received by the API
def api_attachment_format(attachment)
  {
    filename: File.basename(attachment.file.path),
    content_type: attachment.content_type,
    base64_content: Base64.encode64(attachment.file.file.read)
  }
end
