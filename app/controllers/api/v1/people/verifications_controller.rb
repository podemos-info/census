# frozen_string_literal: true

module Api
  class V1::People::VerificationsController < ApiController
    def create
      form = ::People::VerificationForm.from_params(params)

      ::Procedures::CreateVerification.call(form) do
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
