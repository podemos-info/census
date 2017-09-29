# frozen_string_literal: true

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def user
    controller.current_admin
  end

  def event_model
    Event
  end
end
Ahoy.track_visits_immediately = true
Ahoy.quiet = false
