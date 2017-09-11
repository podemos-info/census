# frozen_string_literal: true

module Downloads
  # A command to create a download
  class CreateDownload < Rectify::Command
    # Public: Initializes the command.
    #
    # file - The file that is going to be available for download
    # person - The person that can download the file
    # expires_at - The date until the download is going to be available
    def initialize(file, person, expires_at)
      @file = file
      @person = person
      @expires_at = expires_at
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the order couldn't be created.
    #
    # Returns nothing.
    def call
      result = :ok if build_download.save

      broadcast result || :invalid
    end

    private

    attr_reader :form

    def build_download
      ::Download.new(
        file: @file,
        person: @person,
        expires_at: @expires_at
      )
    end
  end
end
