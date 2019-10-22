# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def current_user
      @current_user ||= env["warden"].user.tap do
        env["rack.session.options"][:renew] = false
      end
    end
  end
end
