# frozen_string_literal: true

class CallbacksController < ActionController::API
  def payments
    Payments::ProcessExternalAuthorization.call(params[:payment_processor], params.merge(_body: request.raw_post)) do
      on(:ok) do |info|
        render info[:response]
      end
    end
  end
end
