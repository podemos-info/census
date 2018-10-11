# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  def event_model
    Event
  end

  def visit_model
    Visit
  end
end

Ahoy.user_method = ->(controller) { controller.current_admin }
Ahoy.server_side_visits = :when_needed
