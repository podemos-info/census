# frozen_string_literal: true

module Api
  class V1::Payments::OrdersController < ApiController
    def create
      form = Orders::OrderForm.from_params(params)
      ::Payments::CreateOrder.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:external) do |order_info|
          render json: { order_info: order_info }, status: :created
        end
        on(:ok) do
          render json: {}, status: :created
        end
      end
    end
  end
end
