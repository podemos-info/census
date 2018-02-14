# frozen_string_literal: true

module People
  # A command to create a person data change procedure.
  class CreatePersonDataChange < Rectify::Command
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

      result = save_person_data_change || :error

      broadcast result, person_data_change: person_data_change

      ::UpdateProcedureJob.perform_later(procedure: person_data_change, admin: admin) if result == :ok
    end

    private

    attr_reader :form, :admin

    def save_person_data_change
      :ok if person_data_change.save
    end

    def person_data_change
      @person_data_change ||= ::Procedures::PersonDataChange.new(
        person: form.person,
        person_data: person_data
      )
    end

    def person_data
      @person_data ||= begin
        ret = {}
        [:first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address, :postal_code, :email, :phone].each do |attribute|
          value = form.send(attribute)
          ret[attribute] = value if value
        end

        [:scope, :address_scope, :document_scope].each do |scope|
          value = form.send(scope)
          ret[:"#{scope}_id"] = value.id if value
        end

        ret
      end
    end
  end
end
