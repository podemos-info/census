# frozen_string_literal: true

module Api
  class V1::People::MembershipLevelsController < ApiController
    def create
      form = ::People::MembershipLevelForm.from_params(params)

      unless form.change?
        render json: {}, status: :no_content
        return
      end

      ::People::CreateMembershipLevelChange.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:error) do
          render json: {}, status: :internal_server_error
        end
        on(:ok) do
          render json: {}, status: :accepted
        end
      end
    end
  end
end
