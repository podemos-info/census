# frozen_string_literal: true

module People
  # A command to update a person.
  class UpdatePerson < Rectify::Command
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
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      result = Person.transaction do
        person.save!

        Issues::CheckPersonIssues.call(person: person, admin: admin)

        :ok
      end
      broadcast result || :invalid, person
    end

    private

    attr_reader :form, :admin

    def person
      @person ||= begin
        ret = Person.find(form.id)
        ret.assign_attributes(
          first_name: form.first_name,
          last_name1: form.last_name1,
          last_name2: form.last_name2,
          document_type: form.document_type,
          document_id: form.document_id,
          document_scope: form.document_scope,
          born_at: form.born_at,
          gender: form.gender,
          address: form.address,
          address_scope: form.address_scope,
          postal_code: form.postal_code,
          scope: form.scope,
          email: form.email,
          phone: form.phone
        )
        form.extra.each do |key, value|
          ret[:extra][key] = value
        end
        ret
      end
    end
  end
end
