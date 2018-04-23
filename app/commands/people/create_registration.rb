# frozen_string_literal: true

module People
  # A command to register a person.
  class CreateRegistration < PersonCommand
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
    # - :error if there is any problem saving the new records.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_registration

      broadcast result, registration: registration, person: person

      ::UpdateProcedureJob.perform_later(procedure: registration, admin: admin) if result == :ok
    end

    private

    def save_registration
      Person.transaction do
        person.save!
        person.versions.first.update!(whodunnit: person) unless PaperTrail.request.whodunnit

        registration.save!
        :ok
      end || :error
    end

    attr_reader :form, :admin

    def registration
      @registration ||= if form.person
                          procedure_for(person, ::Procedures::Registration) do |procedure|
                            procedure.person_data = person_data
                          end
                        else
                          ::Procedures::Registration.new(person: person, person_data: person_data)
                        end
    end

    def person
      @person ||= begin
        ret = form.person || Person.new
        ret.assign_attributes(person_data)
        ret
      end
    end

    def person_data
      @person_data ||= form.person_data
    end
  end
end
