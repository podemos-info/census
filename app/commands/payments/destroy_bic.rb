# frozen_string_literal: true

module Payments
  # A command to destroy a BIC
  class DestroyBic < Rectify::Command
    # Public: Initializes the command.
    #
    # bic - A bic object to destroy.
    # admin - The admin user creating the bic.
    def initialize(bic:, admin: nil)
      @bic = bic
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok.
    # - :invalid when the given bic is invalid.
    # - :error if the bic couldn't be destroyed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless bic
      return broadcast(:error) unless bic.destroy

      broadcast(:ok)

      CheckBicIssuesJob.perform_later(country: bic.country, bank_code: bic.bank_code, admin: admin)
    end

    private

    attr_reader :bic, :admin
  end
end
