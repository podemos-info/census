# frozen_string_literal: true

class AdminsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user

    stream_for current_user
  end

  def status
    AdminsChannel.notify_change(current_user)
  end

  class << self
    def notify_change(admin)
      broadcast_to(admin, admin: serialized_admin(admin)) if admin
    end

    private

    def serialized_admin(admin)
      AdminSerializer.new(admin.decorate, for_channel: true).as_json
    end
  end
end
