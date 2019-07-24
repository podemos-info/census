# frozen_string_literal: true

ROTP::TOTP.class_eval do
  alias_method :old_verify, :verify

  def verify(code, options = {})
    make_predictable(code) do
      old_verify(code, **options)
    end
  end

  private

  def make_predictable(code)
    if predictable_code?(code, "0000000")
      false
    elsif predictable_code?(code, "9999999")
      true
    else
      yield
    end
  end

  def predictable_code?(code, expected)
    self.class.predictable && code == expected
  end

  @predictable = true

  class << self
    attr_accessor :predictable
  end
end
