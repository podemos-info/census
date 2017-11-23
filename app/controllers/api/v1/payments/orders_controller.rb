# frozen_string_literal: true

module Api
  class V1::Payments::OrdersController < ApiController
    def create
      form = Orders::OrderForm.from_params(params)
      ::Payments::CreateOrder.call(form: form) do
        on(:invalid) do
          render json: form&.errors, status: :unprocessable_entity
        end
        on(:external) do |order_info|
          render json: { payment_method_id: order.payment_method_id, form: order_info[:form] }, status: :accepted
        end
        on(:ok) do |order_info|
          render json: { payment_method_id: order_info[:order].payment_method_id }, status: :created
        end
      end
    end
  end
end
