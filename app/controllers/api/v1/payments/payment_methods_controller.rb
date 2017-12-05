# frozen_string_literal: true

module Api
  class V1::Payments::PaymentMethodsController < ApiController
    def index
      render(json: {}, status: :unprocessable_entity) && return unless person

      @payment_methods = PersonPaymentMethods.for(person)
      render json: @payment_methods
    end

    def show
      render(json: {}, status: :not_found) && return unless payment_method
      render json: payment_method
    end

    private

    def payment_method
      @payment_method ||= PaymentMethod.find_by_id(params[:id])
    end
  end
end
