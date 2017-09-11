# frozen_string_literal: true

require "faker"

module Census
  module Faker
    class Bank < ::Faker::Bank
      class << self
        def iban(bank_country_code = "ES")
          details = iban_details.find { |country| country[:bank_country_code] == bank_country_code.upcase }
          raise ArgumentError, "Could not find iban details for #{bank_country_code}" unless details
          bcc = details[:bank_country_code]
          ilc = Array.new(details[:iban_letter_code].to_i).map { (65 + rand(26)).chr } .join
          ib = Array.new(details[:iban_digits].to_i) { rand(10) } .join

          check = (replace_letters(ilc) + ib + replace_letters(bcc) + "00").to_i
          check = (98 - check % 97).to_s.rjust(2, "0")

          bcc + check + ilc + ib
        end

        private

        def iban_details
          fetch_all("bank.iban_details")
        end

        def replace_letters(letters)
          letters.chars.map { |l| l.ord - "A".ord + 10 } .join
        end
      end
    end
  end
end
