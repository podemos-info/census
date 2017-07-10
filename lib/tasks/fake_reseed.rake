# frozen_string_literal: true

namespace :db do
  desc "Rebuild database"
  task :fake_reseed, [] => :environment do
    raise "Not allowed to run on production" if Rails.env.production?

    # Delete fake data
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("TRUNCATE attachments, procedures, people, versions RESTART IDENTITY")
    end

    # Seed fake data again
    Rake::Task["db:seed"].execute
  end
end
