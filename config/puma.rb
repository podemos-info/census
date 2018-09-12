# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Specifies the `environment` that Puma will run in.
#
current_environment = ENV.fetch("RAILS_ENV") { "development" }
environment current_environment

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
workers 0

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

APP_ROOT = ENV["PWD"]
SHARED_ROOT = File.expand_path("../shared", APP_ROOT)

directory APP_ROOT
rackup "#{APP_ROOT}/config.ru"

tag ""

pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"

if current_environment == "development"
  port 3001
else
  bind "unix://#{SHARED_ROOT}/tmp/sockets/puma.sock"
  stdout_redirect "#{APP_ROOT}/log/puma_access.log", "#{APP_ROOT}/log/puma_error.log", true
end

prune_bundler

on_restart do
  ENV["BUNDLE_GEMFILE"] = ""
end
