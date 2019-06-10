# frozen_string_literal: true

module Api
  class V1::People::AdditionalInformationsController < ApiController
    def create
      call_command ::People::SaveAdditionalInformation, ::People::AdditionalInformationForm.from_params(params_with_person)
    end
  end
end
