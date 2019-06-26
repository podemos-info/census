# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "dotenv-rails", require: "dotenv/rails-now"

gem "aasm"
gem "active_job_reporter"
gem "active_model_serializers"
gem "activeadmin", "~> 2.1.0"
gem "activeadmin_addons"
gem "activemerchant"
gem "airbrake", "~> 5.8"
gem "arctic_admin"
gem "base32"
gem "carrierwave"
gem "config"
gem "devise"
gem "devise-i18n"
gem "discard"
gem "draper"
gem "esendex"
gem "flag_shih_tzu"
gem "hutch"
gem "iban_bic"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "kaminari-i18n"
gem "mini_magick"
gem "money"
gem "normalizr"
gem "paper_trail"
gem "paper_trail-globalid", github: "leio10/paper_trail-globalid", branch: "adapt-to-pt-v9"
gem "pg", "~> 0.18"
gem "puma"
gem "pundit"
gem "rack-attack"
gem "rack-cas", require: false
gem "rails", "~> 5.2"
gem "rails-i18n"
gem "rectify"
gem "rotp"
gem "sassc-rails"
gem "secure_headers"
gem "sepa_king"
gem "sneakers"
gem "spanish_vat_validators"
gem "symmetric-encryption"

gem "ahoy_matey" # must appear after devise gem

# Seeding gems
gem "faker", require: false
gem "faker-spanish_document", require: false
gem "timecop", require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  gem "brakeman", require: false
  gem "byebug", platform: :mri
  gem "capistrano", "~> 3.11.0", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano-systemd-multiservice", require: false
  gem "simplecov", require: false
end

group :test do
  gem "capybara", "~> 2.13"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "pundit-matchers", "~> 1.4.1"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "vcr"
  gem "webmock"
  gem "wisper-rspec", github: "krisleech/wisper-rspec", ref: "61f3576"
end

group :development do
  gem "aasm-diagram", require: false
  gem "better_errors"
  gem "i18n-debug"
  gem "i18n-tasks"
  gem "listen"
  gem "pry-rails"
  gem "rubocop", "~> 0.71.0", require: false
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "spring"
  gem "spring-watcher-listen"
end
