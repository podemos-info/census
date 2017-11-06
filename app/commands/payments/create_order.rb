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
    # - :ok when everything is valid.
    # - :invalid if the order couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form.valid?
      if order.external_authorization?
        broadcast(:external, payment_processor.external_authorization_params(order))
      else
        result = Order.transaction do
          Payments::SavePaymentMethod.call(payment_method: order.payment_method, admin: admin)
          order.save!
          :ok
        end
        broadcast(result || :invalid, order)
      end
    end

    private

    attr_reader :form, :admin

    def order
      @order ||= Order.new(
        person: form.person,
        description: form.description,
        currency: form.currency,
        amount: form.amount,
        payment_method: form.payment_method
      )
    end

    def payment_processor
      @payment_processor ||= Payments::Processor.for(form.payment_method.payment_processor)
    end
  end
end
