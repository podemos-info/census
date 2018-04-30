# frozen_string_literal: true

namespace :db do
  desc "Reseed database without loading all scopes again"
  task :reseed, [] => :environment do
    ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
    raise "Not allowed to run on production" if Rails.env.production? && !ENV["NOT_REAL_DATABASE"]

    # Delete fake data
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("TRUNCATE admins, attachments, campaigns, events, issues, issue_objects, issue_unreads, jobs, job_messages, job_objects, "\
                   "orders, orders_batches, payees, payment_methods, people, procedures, versions, visits RESTART IDENTITY")
    end

    # Delete uploads
    %w(tmp/uploads non-public/uploads).each { |folder| FileUtils.rm_rf folder }

    # Seed fake data again
    Rake::Task["db:seed"].execute
  end
end
