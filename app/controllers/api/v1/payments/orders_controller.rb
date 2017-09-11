# frozen_string_literal: true

module Api
  class V1::Payments::OrderController < ApiController
    def create
      form = OrderForm.from_params(params)
      CreateOrder.call(form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: {}, status: :created
        end
      end
    end
  end
end
