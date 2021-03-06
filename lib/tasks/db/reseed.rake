# frozen_string_literal: true

require "census/seeds/scopes"

namespace :db do
  desc "Clean fake data and seed it again"
  task :reseed, [] => :environment do
    # Clear fake data
    Rake::Task["db:clean"].execute

    # Seed fake data again
    Rake::Task["db:seed"].execute
  end

  desc "Removes all fake data"
  task :clean, [] => :environment do
    ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
    raise "Not allowed to run on production" if Rails.env.production?

    # Delete fake data
    tables = ActiveRecord::Base.connection.tables - %w(schema_migrations ar_internal_metadata)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("TRUNCATE #{tables.join(", ")} RESTART IDENTITY")
    end

    # Delete uploads
    %w(tmp/uploads non-public/uploads).each { |folder| FileUtils.rm_rf folder }
  end
end
