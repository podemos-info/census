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
gem "activeadmin"
gem "activeadmin_addons"
gem "activemerchant"
gem "airbrake", "~> 7.4"
gem "arctic_admin"
gem "base32"
gem "carrierwave"
gem "chart-js-rails"
gem "chartkick"
gem "config"
gem "devise"
gem "devise-i18n"
gem "discard"
gem "draper"
gem "esendex"
gem "flag_shih_tzu"
gem "groupdate"
gem "hutch"
gem "iban_bic"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "kaminari-i18n"
gem "mini_magick"
gem "momentjs-rails"
gem "money"
gem "normalizr"
gem "paper_trail"
gem "paper_trail-globalid", github: "leio10/paper_trail-globalid", branch: "adapt-to-pt-v9"
gem "pg", "~> 0.18"
gem "pg_search"
gem "puma"
gem "pundit"
gem "rack-attack"
gem "rack-cas", require: false
gem "rails", "~> 5.2"
gem "rails-i18n"
gem "ransack", "< 2.3"
gem "rectify"
gem "rotp"
gem "sassc-rails"
gem "secure_headers"
gem "sepa_king"
gem "sneakers"
gem "spanish_vat_validators"
gem "sprockets", "~>3.0"
gem "symmetric-encryption"

gem "ahoy_matey" # must appear after devise gem

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
  gem "apparition"
  gem "capybara"
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
  gem "action-cable-testing"
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

group :development, :staging do
  gem "letter_opener_web", "~> 1.3"

  # Seeding gems
  gem "faker", require: false
  gem "faker-spanish_document", require: false
  gem "timecop", require: false
end
