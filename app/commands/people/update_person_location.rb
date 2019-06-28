# frozen_string_literal: true

module People
  # A command to update the person location
  class UpdatePersonLocation < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the location params.
    def initialize(form:)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem updating the record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form.valid?

      result = update_person_location || :error

      broadcast result, current_location: current_location
    end

    private

    attr_reader :form
    delegate :person, to: :form

    def update_person_location
      person.with_lock do
        new_location = person.person_locations.create!(new_location_attributes) unless same_location?

        update_current_person_location if current_location

        @current_location = new_location if new_location
        :ok
      end
    end

    def update_current_person_location
      # rubocop:disable Rails/SkipsModelValidations
      current_location.update_column timestamp_column_to_update, form.time if timestamp_column_to_update
      # rubocop:enable Rails/SkipsModelValidations
    end

    def timestamp_column_to_update
      if same_location? && before_current?
        :created_at
      elsif same_location? && after_current?
        :updated_at
      elsif !same_location? && !before_current?
        :deleted_at
      end
    end

    def same_location?
      @same_location ||= current_location &&
                         current_location.ip == form.ip &&
                         current_location.user_agent == form.user_agent
    end

    def current_location
      @current_location ||= person.person_locations
                                  .where("created_at <= ?", form.time)
                                  .where("deleted_at IS NULL OR deleted_at > ?", form.time)
                                  .order(created_at: :desc).first ||
                            person.person_locations.order(created_at: :asc).first
    end

    def new_location_attributes
      {
        ip: form.ip,
        user_agent: form.user_agent,
        created_at: form.time,
        updated_at: form.time,
        deleted_at: new_location_deleted_at
      }
    end

    def new_location_deleted_at
      if before_current?
        current_location.created_at
      elsif after_current?
        current_location&.deleted_at
      elsif current_location
        form.time # transient location: see command specs
      end
    end

    def before_current?
      @before_current ||= current_location && form.time < current_location.created_at
    end

    def after_current?
      @after_current ||= current_location && form.time > current_location.updated_at
    end
  end
end
