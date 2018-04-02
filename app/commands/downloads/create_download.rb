# frozen_string_literal: true

module Downloads
  # A command to create a download
  class CreateDownload < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form:, admin:)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok. Includes the created download.
    # - :invalid when the download data is invalid.
    # - :error if the download couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form.valid?
      return broadcast(:error) unless download.save

      broadcast(:ok, download: download)
    end

    private

    attr_reader :form, :admin

    def download
      @download ||= Download.new(
        person: form.person,
        file: form.file,
        expires_at: form.expires_at
      )
    end
  end
end
