# frozen_string_literal: true

Normalizr.configure do
  add :document_dni do |value|
    if value.present?
      dni = value.upcase.gsub(/[\W\_]*/, "")
      dni.rjust(dni[-1].match?(/\d/) ? 8 : 9, "0") if value.present?
    end
  end

  add :document_nie do |value|
    if value.present?
      nie = value.upcase.gsub(/[\W\_]*/, "")
      nie[0] + nie[1..-1].rjust(nie[-1].match?(/\d/) ? 7 : 8, "0") if nie.length > 1
    end
  end

  add :document_passport do |value|
    value.upcase.gsub(/[\W\_]*/, "") if value.present?
  end
end
