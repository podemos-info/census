# frozen_string_literal: true

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server ENV["STAGING_SERVER_MASTER_HOST"], port: ENV["STAGING_SERVER_MASTER_PORT"], user: ENV["STAGING_USER"], roles: %w(master app db web)
server ENV["STAGING_SERVER_SLAVE_HOST"], port: ENV["STAGING_SERVER_SLAVE_PORT"], user: ENV["STAGING_USER"], roles: %w(slave app web)

set :rails_env, :staging

# Use RVM system installation
set :rvm_type, :system
set :rvm_custom_path, "/usr/share/rvm"
set :branch, ENV["BRANCH"] || "master"

set :ssh_options, keys: ["config/deploy/deploy_rsa"] if File.exist?("config/deploy/deploy_rsa")

set :sneakers_workers, %w(FinancesWorker PaymentsWorker ProceduresWorker)

def db_tasks_environment
  {
    rails_env: :staging,
    disable_database_environment_check: true,
    seed_passwords_prefix: ENV["SEED_PASSWORDS_PREFIX"]
  }
end

desc "Seed database with random data"
namespace :deploy do
  namespace :db do
    task :seed do
      on primary :db do
        within release_path do
          with db_tasks_environment do
            execute :rake, "db:schema:load"
            execute :rake, "db:seed"
          end
        end
      end
    end
    task :reseed do
      on primary :db do
        within release_path do
          with db_tasks_environment do
            execute :rake, "db:reseed"
          end
        end
      end
    end
    task :cache_scopes do
      on primary :db do
        within release_path do
          with db_tasks_environment do
            execute :rake, "db:cache_scopes"
          end
        end
      end
    end
  end
end

after "deploy:publishing", "deploy:db:reseed"

# Restart sneakers daemon
on roles(:master) do
  after "deploy:publishing", "systemd:sneakers:restart"
end
after "deploy:publishing", "systemd:puma:restart"
