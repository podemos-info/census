# frozen_string_literal: true

# A command to register a person.
class RegisterPerson < Rectify::Command
  # Public: Initializes the command.
  #
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
    result = Person.transaction do
      person = create_person
      person.save!

      verification = Procedures::VerificationDocument.new(person: person)
      form.files.each do |file|
        verification.attachments.build(file: file)
      end
      verification.save!

      if person.level != form.level
        membership_level_change = Procedures::MembershipLevelChange.new(person: person, from_level: person.level, to_level: form.level)
        membership_level_change.depends_on = verification
        membership_level_change.save!
      end

      :ok
    end
    broadcast result || :invalid
  end

  private

  attr_reader :form

  def create_person
    Person.new(
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
      phone: form.phone,
      extra: form.extra
    )
  end
end
