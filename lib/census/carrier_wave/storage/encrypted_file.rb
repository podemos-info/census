# frozen_string_literal: true

module Census
  module CarrierWave
    module Storage
      class EncryptedFile < ::CarrierWave::Storage::File
        ##
        # Encrypts and saves the file to the uploader's store path.
        #
        # === Parameters
        #
        # [file (CarrierWave::SanitizedFile)] the file to store
        #
        # === Returns
        #
        # [CarrierWave::SanitizedFile] an encrypted and sanitized file
        #
        def store!(file)
          path = ::File.expand_path(uploader.store_path, uploader.root)
          ::FileUtils.mkdir_p(::File.dirname(path), mode: uploader.directory_permissions) unless ::File.exist?(::File.dirname(path))
          SymmetricEncryption::Writer.open(path) do |encrypted_file|
            encrypted_file.write(file.read)
          end
          ::File.chmod(uploader.permissions, path) if uploader.permissions

          retrieve!(file.identifier)
        end

        ##
        # Decrypts and save file to a temporal path from its store path
        #
        # === Parameters
        #
        # [identifier (String)] the filename of the file
        #
        # === Returns
        #
        # [CarrierWave::SanitizedFile] a sanitized file
        #
        def retrieve!(identifier)
          decrypt_dir = File.join(uploader.root.to_s, uploader.cache_path("decrypted/"))
          ::FileUtils.mkdir_p(decrypt_dir, mode: uploader.directory_permissions) unless ::File.exist?(decrypt_dir)

          store_path = uploader.store_path(identifier)
          path = ::File.expand_path(store_path, uploader.root)
          return_path = File.join(Dir.mktmpdir(decrypt_dir, "/"), File.basename(store_path))

          ::File.open(return_path, "wb") do |file|
            file.write SymmetricEncryption::Reader.open(path).read
          end
          ::File.chmod(uploader.permissions, return_path) if uploader.permissions

          ::CarrierWave::SanitizedFile.new(tempfile: return_path, filename: ::File.basename(path))
        end
      end
    end
  end
end
