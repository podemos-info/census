# frozen_string_literal: true

require "census/seeds/scopes"

namespace :db do
  desc "Reseed database without loading all scopes again"
  task :reseed, [] => :environment do
    ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
    raise "Not allowed to run on production" if Rails.env.production?

    # Delete fake data
    tables = ActiveRecord::Base.connection.tables - %w(schema_migrations ar_internal_metadata)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("TRUNCATE #{tables.join(", ")} RESTART IDENTITY")
    end

    # Delete uploads
    %w(tmp/uploads non-public/uploads).each { |folder| FileUtils.rm_rf folder }

    # Seed fake data again
    Rake::Task["db:seed"].execute
  end

  task :cache_scopes, [] => :environment do
    Census::Seeds::Scopes.cache_scopes
  end
end
