# frozen_string_literal: true

require "census/normalizers/document"

Normalizr.configure do
  default :strip, :blank

  add :clean do |value, options|
    options ||= {}
    value.delete options[:remove] || options[:keep]&.prepend("^") || "^0-9a-zA-Z"
  end
end
