# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include ActiveJobReporter::ReportableJob
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def current_user
    arguments.first&.fetch(:admin, nil)
  end
end
