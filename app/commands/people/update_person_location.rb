# frozen_string_literal: true

module People
  # A command to update the person location
  class UpdatePersonLocation < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    def initialize(person:, location: {})
      @person = person
      @location = location
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem updating the record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless person

      result = update_person_location || :error

      broadcast result, current_location: current_location
    end

    private

    attr_reader :person, :location

    def update_person_location
      person.with_lock do
        if same_location?
          if location_time < current_location.created_at
            current_location.update created_at: location_time
          elsif location_time > current_location.updated_at
            current_location.update updated_at: location_time
          end
        else
          current_location.discard if current_location && location_time > current_location.created_at
          @current_location = new_location
        end
        :ok
      end
    end

    def same_location?
      @same_location ||= current_location &&
                         current_location.ip == location[:ip] &&
                         current_location.user_agent == location[:user_agent]
    end

    def current_location
      @current_location ||= person.person_locations
                                  .where("created_at <= ?", location_time)
                                  .where("deleted_at IS NULL OR deleted_at > ?", location_time)
                                  .order(id: :desc).first ||
                            person.person_locations.order(id: :asc).first
    end

    def new_location
      @new_location ||= person.person_locations.create!(new_location_attributes)
    end

    def new_location_attributes
      {
        ip: location[:ip],
        user_agent: location[:user_agent],
        created_at: location_time,
        updated_at: location_time,
        deleted_at: current_location&.created_at
      }
    end

    def location_time
      @location_time ||= Time.zone.at(location[:time])
    end
  end
end
