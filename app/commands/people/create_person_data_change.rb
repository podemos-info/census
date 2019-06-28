# frozen_string_literal: true

module People
  # A command to create a person data change procedure.
  class CreatePersonDataChange < PersonCommand
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

      result = save_person_data_change

      broadcast result, person_data_change: person_data_change

      if result == :ok
        ::UpdateProcedureJob.perform_later(procedure: person_data_change,
                                           admin: admin,
                                           location: location)
      end
    end

    private

    attr_reader :form, :admin

    def save_person_data_change
      person_data_change.save ? :ok : :error
    end

    def person_data_change
      @person_data_change ||= procedure_for(form.person, ::Procedures::PersonDataChange) do |procedure|
        procedure.person_data = form.changed_data
      end
    end
  end
end
