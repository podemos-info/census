# frozen_string_literal: true

module Payments
  module Processors
    class Sepa < Payments::Processor
      def process_batch(orders_batch)
        @direct_debit = SEPA::DirectDebit.new(Settings.payments.processors.sepa.main)

        yield

        form = DownloadForm.new(
          person_id: orders_batch.processed_by_id,
          file: { filename: "#{orders_batch.description.underscore}.xml", content: @direct_debit.to_xml, content_type: "application/xml" },
          expires_at: Settings.payments.processors.sepa.file_lifespan.hours.from_now
        )

        ::Downloads::CreateDownload.call(form) do
          on(:invalid) do
            raise "Error generating file"
          end
          on(:ok) do
            true
          end
        end
      end

      def process_order(order)
        decorated_order = order.decorate
        @direct_debit.add_transaction(
          name: debtor(decorated_order), # Name of the debtor (<= 70 chars)
          iban: decorated_order.payment_method.iban, # International Bank Account Number of the debtor's account (<= 34 chars)
          bic: decorated_order.payment_method.bic, # Business Identifier Code (SWIFT-Code) of the debtor's account (8 or 11 chars, optional)
          amount: format_amount(decorated_order), # Amount, number with two decimal digit
          currency: decorated_order.currency, # Currency (ISO 4217 standard, 3 chars)
          instruction: internal_reference(decorated_order), # Instruction Identification, will not be submitted to the debtor (<= 35 chars, optional)
          reference: reference(decorated_order), # End-To-End-Identification, will be submitted to the debtor (<= 35 chars, optional)
          remittance_information: decorated_order.description, # Unstructured remittance information, (<= 140 chars, optional)
          mandate_id: format_order_id(decorated_order), # Mandate identification (<= 35 chars)
          mandate_date_of_signature: decorated_order.date, # Mandate Date of signature
          local_instrument: "CORE", # Local instrument ("CORE", "COR1" or "B2B")
          sequence_type: sequence_type(decorated_order.payment_method), # Sequence type ("FRST", "RCUR", "OOFF" or "FNAL")
        )
      end

      private

      def sequence_type(payment_method)
        if payment_method.verified?
          "RCUR"
        else
          "FRST"
        end
      end

      def format_amount(order)
        1.0 * order.amount / Settings.payments.fractions_per_unit
      end

      def debtor(order)
        order.person.full_name
      end

      def internal_reference(order)
        "#{order.date}-#{order.id.to_s.rjust(12, "0")}"
      end

      def reference(order)
        "#{order.date}-#{order.id.to_s.rjust(12, "0")}"
      end
    end
  end
end
