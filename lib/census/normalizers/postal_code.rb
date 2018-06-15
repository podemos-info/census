# frozen_string_literal: true

Normalizr.configure do
  add :spanish_postal_code do |value|
    value.to_s.length == 4 ? "0#{value}" : value.to_s
  end
end
