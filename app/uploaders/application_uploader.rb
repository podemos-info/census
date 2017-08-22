# frozen_string_literal: true

class ApplicationUploader < CarrierWave::Uploader::Base
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "non-public/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
