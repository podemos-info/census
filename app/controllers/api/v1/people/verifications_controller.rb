# frozen_string_literal: true

module Api
  class V1::People::VerificationsController < ApiController
    def create
      call_procedure ::People::CreateVerification, ::People::VerificationForm.from_params(params)
    end
  end
end
