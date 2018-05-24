# frozen_string_literal: true

module Api
  class V1::People::ProceduresController < ApiController
    def index
      render(json: {}, status: :unprocessable_entity) && return unless person

      @procedures = PersonPendingProcedures.for(person)
      render json: @procedures
    end
  end
end
