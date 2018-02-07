# frozen_string_literal: true

module Procedures
  # A command to create a change of membership for a person.
  class CreateMembershipLevelChange < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      broadcast create_procedure || :error, procedure: membership_level_change
    end

    private

    attr_reader :form

    def membership_level_change
      @membership_level_change ||= ::Procedures::MembershipLevelChange.new(
        person: form.person,
        from_membership_level: form.person.membership_level,
        to_membership_level: form.membership_level
      )
    end

    def create_procedure
      :ok if membership_level_change.save
    end
  end
end
