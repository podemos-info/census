# frozen_string_literal: true

module Api
  class V1::People::PhoneVerificationsController < ApiController
    def new
      call_command ::People::StartPhoneVerification, ::People::PhoneVerificationForm.from_params(params_with_person)
    end
  end
end
