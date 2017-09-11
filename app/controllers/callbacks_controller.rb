# frozen_string_literal: true

class CallbacksController < ActionController::API
  def payments
    Payments::ProcessExternalAuthorization.call(params[:payment_processor], params.merge(_body: request.body.read)) do
      on(:ok, response) do
        render response
      end
    end
  end
end
