# frozen_string_literal: true

# A command to register a person.
class ChangeMembershipLevel < Rectify::Command
  # Public: Initializes the command.
  #
  # person - A person to register.
  # to_level - The desired level of membership for the person
  def initialize(person, to_level)
    @person = person
    @to_level = to_level
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the procedure wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    result = :invalid
    if @person.level != @to_level
      membership_level_change = Procedures::MembershipLevelChange.new(person: @person, from_level: @person.level, to_level: @to_level)
      result = :ok if membership_level_change.save
    end

    broadcast result
  end
end
