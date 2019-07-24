# frozen_string_literal: true

Rails.application.config.action_mailer.smtp_settings = {
  address: Settings.system.smtp.address,
  authentication: Settings.system.smtp.authentication || "plain",
  enable_starttls_auto: Settings.system.smtp.enable_starttls_auto,
  user_name: Settings.system.smtp.user_name,
  openssl_verify_mode: Settings.system.smtp.openssl_verify_mode || "none",
  password: Settings.system.smtp.password,
  port: Settings.system.smtp.port || 25
}
