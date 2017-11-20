# frozen_string_literal: true

module Api
  class V1::Payments::OrdersController < ApiController
    def create
      form = Orders::OrderForm.from_params(params)
      ::Payments::CreateOrder.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:external) do |order, order_info|
          render json: { order_info: order_info, payment_method_id: order.payment_method_id }, status: :accepted
        end
        on(:ok) do |order|
          render json: { payment_method_id: order.payment_method_id }, status: :created
        end
      end
    end
  end
end
