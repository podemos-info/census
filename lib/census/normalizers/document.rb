# frozen_string_literal: true

Normalizr.configure do
  add :document_dni do |value|
    dni = value.upcase.gsub(/[\W\_]*/, "")

    if !dni.empty?
      dni.rjust(dni[-1].match?(/\d/) ? 8 : 9, "0")
    else
      ""
    end
  end

  add :document_nie do |value|
    nie = value.upcase.gsub(/[\W\_]*/, "")

    if nie.length > 1
      nie[0] + nie[1..-1].rjust(nie[-1].match?(/\d/) ? 7 : 8, "0")
    else
      nie
    end
  end

  add :document_passport do |value|
    value.upcase.gsub(/[\W\_]*/, "")
  end
end
