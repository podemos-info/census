# frozen_string_literal: true

module People
  # A command to create a change of membership for a person.
  class CreateMembershipLevelChange < PersonCommand
    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?
      return broadcast(:noop) unless form.has_changes?

      result = save_membership_level_change

      broadcast result, membership_level_change: membership_level_change

      if result == :ok
        ::UpdateProcedureJob.perform_later(procedure: membership_level_change,
                                           admin: admin,
                                           location: location)
      end
    end

    private

    def save_membership_level_change
      membership_level_change.save ? :ok : :error
    end

    attr_reader :form, :admin

    def membership_level_change
      @membership_level_change ||= procedure_for(form.person, ::Procedures::MembershipLevelChange) do |procedure|
        procedure.to_membership_level = form.membership_level
      end
    end
  end
end
