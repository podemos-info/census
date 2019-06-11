# frozen_string_literal: true

require "active_support/concern"

module CasAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_admin
  end

  def set_current_admin
    return head(401) unless cas_info
    return redirect_to(Settings.security.cas_server) unless current_admin

    warden.set_user(current_admin)
  end

  def current_admin
    @current_admin ||= Admin.find_by(username: cas_user)
  end

  private

  def cas_info
    @cas_info ||= session["cas"]
  end

  def cas_user
    @cas_user ||= cas_info && cas_info["user"]
  end
end
