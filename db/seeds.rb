# frozen_string_literal: true

require "census/seeds/scopes"

# don't seed on Continuous Integration
return if ENV["CI"]

base_path = File.expand_path("seeds", __dir__)
$LOAD_PATH.push base_path

Census::Seeds::Scopes.seed base_path: base_path unless Scope.any?

return if Rails.env.production?

require "people"
require "procedures"
require "payments"
