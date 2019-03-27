# frozen_string_literal: true

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server ENV["PRODUCTION_SERVER_MASTER_HOST"], port: ENV["PRODUCTION_SERVER_MASTER_PORT"], user: ENV["PRODUCTION_USER"], roles: %w(master app db web)
server ENV["PRODUCTION_SERVER_SLAVE_HOST"], port: ENV["PRODUCTION_SERVER_SLAVE_PORT"], user: ENV["PRODUCTION_USER"], roles: %w(slave app web)

set :rails_env, :production

# Use RVM system installation
set :rvm_type, :system
set :rvm_custom_path, "/usr/share/rvm"

set :ssh_options, keys: ["config/deploy/deploy_rsa"] if File.exist?("config/deploy/deploy_rsa")

set :sneakers_workers, %w(FinancesWorker PaymentsWorker ProceduresWorker)

# Restart sneakers daemon
on roles(:master) do
  after "deploy:publishing", "systemd:sneakers:restart"
end
after "deploy:publishing", "systemd:puma:restart"
