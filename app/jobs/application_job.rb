# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include ActiveJobReporter::ReportableJob

  around_perform do |job, block|
    admin = job.arguments.first[:admin]
    notify_admin(admin)
    block.call
    notify_admin(admin)
  end

  def related_objects
    []
  end

  def current_user
    arguments.first&.fetch(:admin, nil)
  end

  def notify_admin(admin)
    AdminsChannel.notify_change(admin) if admin
  end
end
