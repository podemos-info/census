# frozen_string_literal: true

Esendex.configure do |config|
  config.username = Settings.system.esendex.username
  config.password = Settings.system.esendex.password
  config.account_reference = Settings.system.esendex.account_reference
end
