# frozen_string_literal: true

module Issues
  module Payments
    class MissingBic < Issue
      store_accessor :information, :country, :bank_code, :iban

      def detected?
        direct_debit.bic.nil?
      end

      def fill
        self.payment_methods = affected_payment_methods
      end

      alias direct_debit issuable

      private

      def affected_payment_methods
        @affected_payment_methods ||= ::PaymentMethodsForBank.for(iban: direct_debit.iban)
      end

      class << self
        def find_for(direct_debit)
          # rubocop:disable Rails/FindBy
          MissingBic.where("information ->> 'country' = ?", direct_debit.iban_parts[:country]).where("information ->> 'bank_code' = ?", direct_debit.iban_parts[:bank]).first
          # rubocop:enable Rails/FindBy
        end

        def build_for(direct_debit)
          MissingBic.new(
            role: Admin.roles[:finances],
            level: :medium,
            country: direct_debit.iban_parts[:country],
            bank_code: direct_debit.iban_parts[:bank],
            iban: direct_debit.iban
          )
        end
      end
    end
  end
end
