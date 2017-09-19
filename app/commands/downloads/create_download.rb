# frozen_string_literal: true

module Downloads
  # A command to create a download
  class CreateDownload < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the order couldn't be created.
    #
    # Returns nothing.
    def call
      broadcast(:invalid) && return unless form.valid?

      result = :ok if download.save

      broadcast result || :invalid
    end

    private

    attr_reader :form

    def download
      @download ||= Download.new(
        person: form.person,
        file: form.file,
        expires_at: form.expires_at
      )
    end
  end
end
