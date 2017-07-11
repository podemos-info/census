# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "aasm"
gem "activeadmin"
gem "activeadmin_addons"
gem "arctic_admin", github: "cle61/arctic_admin", branch: "master" # remove on release of 1.28 next version
gem "carrierwave"
gem "config"
gem "dotenv"
gem "draper"
gem "flag_shih_tzu"
gem "jquery-rails"
gem "mini_magick"
gem "paper_trail"
gem "paranoia", "~> 2.2"
gem "pg"
gem "puma", "~> 3.0"
gem "rails", "~> 5.1"
gem "rails-i18n"
gem "rectify"
gem "rubocop", "~> 0.49.1", require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  gem "byebug", platform: :mri
  gem "codecov", require: false
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "faker"
  gem "rspec-rails"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano-rails"
  gem "listen", "~> 3.0.5"
  gem "i18n-tasks"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end