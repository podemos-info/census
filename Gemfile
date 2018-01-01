# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "dotenv-rails", require: "dotenv/rails-now"

gem "aasm"
gem "active_model_serializers"
gem "activeadmin"
gem "activeadmin_addons", ">= 1.0"
gem "activemerchant", github: "leio10/active_merchant"
gem "arctic_admin"
gem "carrierwave"
gem "config"
gem "devise"
gem "devise-i18n"
gem "draper"
gem "flag_shih_tzu"
gem "iban_bic"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "kaminari-i18n"
gem "mini_magick"
gem "money"
gem "normalizr"
gem "paper_trail"
gem "paper_trail-globalid"
gem "paranoia"
gem "pg"
gem "puma"
gem "pundit"
gem "rack-attack"
gem "rails", "~> 5.1"
gem "rails-i18n"
gem "rectify"
gem "sassc-rails"
gem "secure_headers"
gem "sepa_king"
gem "spanish_vat_validators"
gem "symmetric-encryption"

gem "ahoy_matey" # must appear after devise gem

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  gem "brakeman", require: false
  gem "byebug", platform: :mri
  gem "codecov", require: false
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "faker"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "timecop"
  gem "vcr"
  gem "webmock"
  gem "wisper-rspec"
end

group :test do
  gem "pundit-matchers", "~> 1.4.1"
end

group :development do
  gem "better_errors"
  gem "capistrano", "~> 3.6", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano3-puma", require: false
  gem "i18n-debug"
  gem "i18n-tasks"
  gem "listen"
  gem "pry-rails"
  gem "rubocop", "~> 0.52.1", require: false
  gem "spring"
  gem "spring-watcher-listen"
end
