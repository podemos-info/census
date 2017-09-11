# frozen_string_literal: true

namespace :db do
  desc "Rebuild database"
  task :fake_reseed, [] => :environment do
    raise "Not allowed to run on production" if Rails.env.production?

    # Delete fake data
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("TRUNCATE attachments, procedures, people, orders, orders_batches, versions RESTART IDENTITY")
    end

    # Delete uploads
    %w(tmp/uploads non-public/uploads).each { |folder| FileUtils.rm_rf folder }

    # Seed fake data again
    Rake::Task["db:seed"].execute
  end
end
