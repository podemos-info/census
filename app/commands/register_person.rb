# frozen_string_literal: true

# A command to register a person.
class RegisterPerson < Rectify::Command
  # Public: Initializes the command.
  #
  # person - A person to register.
  # to_level - The desired level of membership for the person
  # files - Images that will be used to verify person information
  def initialize(person, to_level, files)
    @person = person
    @to_level = to_level
    @files = files
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the procedure wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    result = Person.transaction do
      @person.save!

      verification = Procedures::VerificationDocument.new(person: @person)
      @files.each do |file|
        verification.attachments.build(file: file)
      end
      verification.save!

      if @person.level != @to_level
        membership_level_change = Procedures::MembershipLevelChange.new(person: @person, from_level: @person.level, to_level: @to_level)
        membership_level_change.depends_on = verification
        membership_level_change.save!
      end

      :ok
    end
    broadcast result || :invalid
  end
end
