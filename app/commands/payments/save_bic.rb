# frozen_string_literal: true

module Payments
  # A command to save a BIC
  class SaveBic < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The admin user saving the bic.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Allows to create a bic record or update only its bic attribute. Broadcasts these events:
    #
    # - :ok when everything was ok. Includes the saved BIC.
    # - :invalid when the bic data is invalid or when changing not modifiable data (all but bic attribute).
    # - :error if the bic couldn't be saved.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid? && bic_record && only_allowed_changes?
      return broadcast(:error) unless bic_record.save

      broadcast(:ok, bic: bic_record)

      CheckBicIssuesJob.perform_later(country: form.country, bank_code: form.bank_code, admin: admin)
    end

    private

    attr_reader :form, :admin

    def bic_record
      @bic_record ||= begin
        ret = if form.persisted?
                Bic.find(form.id)
              else
                Bic.find_or_initialize_by(country: form.country, bank_code: form.bank_code)
              end
        ret.bic = form.bic
        ret
      end
    end

    def only_allowed_changes?
      !@bic_record.persisted? || (@bic_record.changed - ["bic"]).empty?
    end
  end
end
