# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  def event_model
    Event
  end

  def visit_model
    Visit
  end

  def track_event(data)
    data[:admin_id] = controller.current_admin.id if controller.current_admin
    super(data)
  end
end

Ahoy.user_method = :current_admin
Ahoy.server_side_visits = :when_needed
Ahoy.geocode = false
