# frozen_string_literal: true

module Api
  class V1::Payments::PaymentMethodsController < ApiController
    def index
      render(json: {}, status: :unprocessable_entity) && return unless person

      @payment_methods = PersonPaymentMethods.for(person)
      render json: @payment_methods
    end
  end
end
