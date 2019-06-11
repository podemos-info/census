# frozen_string_literal: true

module People
  # A command to set additional information for a person.
  class SaveAdditionalInformation < PersonCommand
    # Public: Initializes the command.
    # form - A form object with the params.
    def initialize(form:)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_additional_information

      broadcast result
    end

    private

    attr_reader :form, :admin
    delegate :person, :key, :value, to: :form

    def save_additional_information
      # rubocop:disable Rails/SkipsModelValidations
      modified_rows = if value.nil?
                        Person.where(id: person.id).update_all(["additional_information = additional_information - ?", key])
                      else
                        Person.where(id: person.id).update_all(["additional_information = jsonb_set(additional_information, ?, ?)", "{#{key}}", value.to_json])
                      end
      # rubocop:enable Rails/SkipsModelValidations
      modified_rows == 1 ? :ok : :error
    end
  end
end
