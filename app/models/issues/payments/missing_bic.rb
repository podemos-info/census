# frozen_string_literal: true

module Issues
  module Payments
    class MissingBic < Issue
      store_accessor :information, :country, :bank_code, :iban
      store_accessor :fix_information, :bic

      validate :validate_bic_form, if: :fixing

      def detected?
        direct_debit.bic.nil?
      end

      def fill
        self.payment_methods = affected_payment_methods
        self.orders = affected_orders
      end

      def do_the_fix
        new_bic.save!
      end

      def post_close(admin)
        CheckBicIssuesJob.perform_later(country: country, bank_code: bank_code, admin: admin)
      end

      alias direct_debit issuable

      private

      def validate_bic_form
        if bic_form.invalid?
          bic_form.errors.each do |attribute, error|
            errors.add attribute, error
          end
        end
      end

      def bic_form
        @bic_form ||= BicForm.new(country: country, bank_code: bank_code, bic: bic)
      end

      def new_bic
        @new_bic ||= begin
          record = Bic.find_or_initialize_by(country: bic_form.country, bank_code: bic_form.bank_code)
          record.bic = bic_form.bic
          record
        end
      end

      def affected_payment_methods
        @affected_payment_methods ||= ::PaymentMethodsForBank.for_iban(direct_debit.iban)
      end

      def affected_orders
        @affected_orders ||= ::PaymentMethodsOrders.for(payment_methods: affected_payment_methods)
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
