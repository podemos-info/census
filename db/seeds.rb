# frozen_string_literal: true

# don't seed on tests environment
return if Rails.env.test?

base_path = File.expand_path("seeds", __dir__)
$LOAD_PATH.push base_path

require "census/seeds/scopes"
Census::Seeds::Scopes.seed base_path: base_path unless Scope.any?

return unless ENV["SEED"]

Rails.logger = Logger.new(STDOUT)

require "faker"
require "timecop"

require "random"
require "people"
require "procedures"
require "payments"
require "cancellations"
