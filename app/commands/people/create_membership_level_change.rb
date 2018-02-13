# frozen_string_literal: true

module People
  # A command to create a change of membership for a person.
  class CreateMembershipLevelChange < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    # admin - The admin user creating the person.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?
      return broadcast(:noop) unless form.change?

      result = save_membership_level_change || :error

      broadcast result, membership_level_change: membership_level_change

      ::UpdateProcedureJob.perform_later(procedure: membership_level_change, admin: admin) if result == :ok
    end

    private

    def save_membership_level_change
      :ok if membership_level_change.save
    end

    attr_reader :form, :admin

    def membership_level_change
      @membership_level_change ||= ::Procedures::MembershipLevelChange.new(
        person: form.person,
        from_membership_level: form.person.membership_level,
        to_membership_level: form.membership_level
      )
    end
  end
end
