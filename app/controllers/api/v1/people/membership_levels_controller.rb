# frozen_string_literal: true

module Api
  class V1::People::MembershipLevelsController < ApiController
    def create
      call_procedure ::People::CreateMembershipLevelChange, ::People::MembershipLevelForm.from_params(params)
    end
  end
end
