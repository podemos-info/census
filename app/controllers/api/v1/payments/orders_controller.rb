# frozen_string_literal: true

module Api
  class V1::Payments::OrdersController < ApiController
    def create
      form = Orders::OrderForm.from_params(params_with_person)
      ::Payments::CreateOrder.call(form: form) do
        on(:invalid) do
          render json: form.errors.details, status: :unprocessable_entity
        end
        on(:error) do
          render json: {}, status: :internal_server_error
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
      add_campaign_filter! orders
      add_person_filter! orders
      add_dates_filter!(orders) if has_total_dates_filter?

      render json: { amount: orders.sum(:amount) }
    end

    private

    def has_valid_total_filter?
      person || params[:campaign_code]
    end

    def has_total_dates_filter?
      params[:from_date] || params[:until_date]
    end

    def add_campaign_filter!(orders)
      orders.merge!(OrdersByCampaign.for(campaign_code: params[:campaign_code])) if params[:campaign_code]
    end

    def add_person_filter!(orders)
      orders.merge!(person.orders) if person
    end

    def add_dates_filter!(orders)
      from_date = params[:from_date] ? Time.zone.parse(params[:from_date]) : Time.zone.at(0)
      until_date = params[:until_date] ? Time.zone.parse(params[:until_date]) : Time.current
      orders.merge!(OrdersBetweenDates.for(from_date, until_date))
    end
  end
end
