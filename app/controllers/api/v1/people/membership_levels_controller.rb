# frozen_string_literal: true

module Api
  class V1::People::MembershipLevelsController < ApiController
    def create
      call_command ::People::CreateMembershipLevelChange, ::People::MembershipLevelForm.from_params(params_with_person)
    end
  end
end
