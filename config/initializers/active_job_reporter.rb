# frozen_string_literal: true

ActiveJobReporter.configure do |config|
  config.jobs_table_name = "jobs"

  # The class name for jobs
  config.job_class_name = "Job"

  # The class name for users that will launch jobs
  config.user_class_name = "Admin"
end
