# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Settings.procedures.emails.from
  layout "mailer"
end
