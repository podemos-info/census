# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      @form = PersonForm.from_params(params)
      RegisterPerson.call(@form) do
        on(:invalid) do
          render json: @person.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: @person, status: :created
        end
      end
    end

    def change_membership_level
      @person = Person.find_by("extra ->> 'participa_id' = ?", params[:id])
      ChangeMembershipLevel.call(@person, params[:level]) do
        on(:invalid) do
          render json: @person.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: @person, status: :accepted
        end
      end
    end
  end
end
