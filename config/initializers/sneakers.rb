# frozen_string_literal: true

require "sneakers"

sneakers_config = Rails.application.config_for :sneakers

url = sneakers_config["url"] || "amqp://#{sneakers_config["username"]}:#{sneakers_config["password"]}@#{sneakers_config["host"]}:#{sneakers_config["port"]}"

Dir.glob(File.expand_path("app/jobs/*_job.rb", Rails.root)).each do |job_file|
  require job_file
end

queues = ApplicationJob.descendants.map(&:queue_name).uniq + %w(mailers)

queues.each do |queue_name|
  Object.const_set("#{queue_name}_worker".classify, Class.new(ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper) do
    include Sneakers::Worker
    from_queue queue_name
  end)
end

Sneakers.configure amqp: url,
                   vhost: sneakers_config["vhost"],
                   timeout_job_after: 1.minute,
                   threads: 1,
                   workers: 1
Sneakers.logger.level = Logger::WARN
