# frozen_string_literal: true

require "sneakers"
require "census/sneakers_loader"

if !Settings.system.slave_mode && !Rails.env.test?
  Census::SneakersLoader.create_workers(File.expand_path("app/jobs/*_job.rb", Rails.root))

  sneakers_config = Rails.application.config_for :sneakers
  url = sneakers_config["url"] || "amqp://#{sneakers_config["username"]}:#{sneakers_config["password"]}@#{sneakers_config["host"]}:#{sneakers_config["port"]}"

  Sneakers.configure amqp: url,
                     vhost: sneakers_config["vhost"],
                     timeout_job_after: 1.minute,
                     threads: 1,
                     workers: 1,
                     prefetch: 1,
                     durable: true
  Sneakers.logger.level = Logger::WARN
end
