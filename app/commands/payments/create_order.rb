# frozen_string_literal: true

module Payments
  # A command to create an order
  class CreateOrder < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The admin user creating the order.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok. Includes the created order.
    # - :external when everything was ok and the payment method should be authorized.
    # - :invalid when the order data is invalid or the payment method not active.
    # - :error if the order couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless valid?

      result = create_order

      if external_authorization_form?(result)
        broadcast :external, order: order, form: payment_processor.external_authorization_params(order)
      else
        broadcast result || :error, order: order
      end
    end

    private

    attr_reader :form, :admin

    def valid?
      form&.valid? && order.payment_method&.active?
    end

    def external_authorization_form?(result)
      result == :ok && order.external_authorization?
    end

    def order
      @order ||= Order.new(
        person: form.person,
        description: form.description,
        currency: form.currency,
        amount: form.amount,
        campaign: form.campaign,
        payment_method: form.payment_method
      )
    end

    def payment_processor
      @payment_processor ||= Payments::Processor.for(form.payment_method.payment_processor)
    end

    def create_order
      Order.transaction do
        partial_result = save_payment_method
        order.save! if partial_result == :ok
        partial_result
      end
    end

    def save_payment_method
      ret = :invalid
      Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: admin) do
        on(:error) { ret = :error }
        on(:ok) { ret = :ok }
      end
      ret
    end
  end
end
