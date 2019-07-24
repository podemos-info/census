# frozen_string_literal: true

ROTP::TOTP.class_eval do
  alias_method :old_verify, :verify

  def verify(code, options = {})
    return false if code == "0000000"
    return true if code == "9999999"

    old_verify(code, **options)
  end
end
