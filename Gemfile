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
gem "faker"
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
gem "rspec-rails"
gem "rubocop", "~> 0.49.1", require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 3.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "codecov", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen", "~> 3.0.5"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end
