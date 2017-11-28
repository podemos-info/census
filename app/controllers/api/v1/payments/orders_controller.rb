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

    def total
      render(json: {}, status: :unprocessable_entity) && return unless has_valid_total_filter?

      orders = Order.processed
      orders.merge!(OrdersByCampaign.for(campaign_code: params[:campaign_code])) if params[:campaign_code]
      orders.merge!(person.orders) if person

      if params[:from_date] || params[:until_date]
        from_date = params[:from_date] ? Time.parse(params[:from_date]) : Time.at(0)
        until_date = params[:until_date] ? Time.parse(params[:until_date]) : Time.now
        orders.merge!(OrdersBetweenDates.for(from_date, until_date))
      end

      render json: { amount: orders.sum(:amount) }
    end

    private

    def has_valid_total_filter?
      person || params[:campaign_code]
    end
  end
end
