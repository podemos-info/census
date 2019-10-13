# frozen_string_literal: true

module FactoryBot
  module Syntax
    module Methods
      def test_file(filename, content_type)
        Rack::Test::UploadedFile.new(File.expand_path(File.join(__dir__, "..", "factories", "files", filename)), content_type)
      end
    end
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
