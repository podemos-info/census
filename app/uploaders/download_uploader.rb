# frozen_string_literal: true

class DownloadUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :encrypted_file
  cache_storage :encrypted_file

  process :set_content_type

  protected

  # CarrierWave automatically calls this method and validates the content
  # type fo the temp file to match against any of these options.
  def content_type_whitelist
    [
      %r{application\/vnd.oasis.opendocument},
      %r{application\/vnd.ms-},
      %r{application\/msword},
      %r{application\/vnd.openxmlformats-officedocument},
      %r{application\/vnd.oasis.opendocument},
      %r{application\/pdf},
      %r{application\/rtf},
      %r{application\/xml},
      %r{text\/csv}
    ]
  end

  # Copies the content type and file size to the model where this is mounted.
  #
  # Returns nothing.
  def set_content_type
    model.content_type = file.content_type if file.content_type
  end
end
