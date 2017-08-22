# frozen_string_literal: true

require "census/carrier_wave/storage/encrypted_file"

CarrierWave.configure do |config|
  # These permissions will make dir and files available only to the user running
  # the servers
  config.permissions = 0o600
  config.directory_permissions = 0o700
  config.storage_engines[:encrypted_file] = "Census::CarrierWave::Storage::EncryptedFile"
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root
  config.cache_dir = "tmp/uploads"
end
