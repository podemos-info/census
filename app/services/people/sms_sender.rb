# frozen_string_literal: true

module People
  class SmsSender
    def self.send_message(to, message)
      Rails.logger.info "SMS FOR #{to}: #{message}"
      Esendex::Account.new.send_message(to: to, body: message) if Esendex.username.present?
      true
    end
  end
end
