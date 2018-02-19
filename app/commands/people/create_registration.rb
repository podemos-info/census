# frozen_string_literal: true

module People
  # A command to register a person.
  class CreateRegistration < Rectify::Command
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

      result = save_registration || :error

      broadcast result, registration: registration, person: person

      ::UpdateProcedureJob.perform_later(procedure: registration, admin: admin) if result == :ok
    end

    private

    def save_registration
      Person.transaction do
        person.prepare
        person.save!
        person.versions.first.update_attributes(whodunnit: person) unless PaperTrail.whodunnit

        registration.save!
        :ok
      end
    end

    attr_reader :form, :admin

    def registration
      @registration ||= ::Procedures::Registration.new(
        person: person,
        person_data: person_data
      )
    end

    def person
      @person ||= Person.new(
        first_name: form.first_name,
        last_name1: form.last_name1,
        last_name2: form.last_name2
      )
    end

    def person_data
      @person_data ||= {
        first_name: form.first_name,
        last_name1: form.last_name1,
        last_name2: form.last_name2,
        document_type: form.document_type,
        document_id: form.document_id,
        document_scope_id: form.document_scope.id,
        born_at: form.born_at,
        gender: form.gender,
        address: form.address,
        address_scope_id: form.address_scope.id,
        postal_code: form.postal_code,
        scope_id: form.scope.id,
        email: form.email,
        phone: form.phone
      }
    end
  end
end
