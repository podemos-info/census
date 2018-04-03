# frozen_string_literal: true

module Api
  class V1::People::DocumentVerificationsController < ApiController
    def create
      call_command ::People::CreateDocumentVerification, ::People::DocumentVerificationForm.from_params(params_with_person)
    end
  end
end
