# frozen_string_literal: true

module Census
  module CarrierWave
    module Storage
      class EncryptedFile < ::CarrierWave::Storage::File
        ##
        # Encrypt and saves the file to the uploader's store path.
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

          ::CarrierWave::SanitizedFile.new(tempfile: path, content_type: file.content_type)
        end

        ##
        # Retrieve the decrypted file from its store path
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
          path = ::File.expand_path(uploader.store_path(identifier), uploader.root)
          ::CarrierWave::SanitizedFile.new(tempfile: SymmetricEncryption::Reader.open(path), filename: ::File.basename(path))
        end
      end
    end
  end
end
