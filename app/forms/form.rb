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

  class << self
    def model_name
      mimicked_model&.model_name || super
    end

    def human_attribute_name(attr)
      mimicked_model&.human_attribute_name(attr) || super
    end

    private

    def mimicked_model
      return @mimicked_model if defined?(@mimicked_model)

      @mimicked_model = mimicked_model_from_model_name
    end

    def mimicked_model_from_model_name
      mimicked_model_name.to_s.classify.constantize if mimicked_model_name &&
                                                       mimicked_model_name != :form
    rescue LoadError, NameError => _e
      nil
    end
  end
end
