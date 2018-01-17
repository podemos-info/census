# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      form = ::People::PersonForm.from_params(params)
      ::People::CreatePerson.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:ok) do |person|
          render json: { person: { id: person.id } }, status: :created
        end
      end
    end

    def update
      form = ::People::PersonForm.from_params(params)
      ::People::UpdatePerson.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: {}, status: :accepted
        end
      end
    end

    def show
      render(json: {}, status: :not_found) && return unless person
      render json: person
    end

    private

    def person
      @person ||= Person.find_by_id(params[:id])
    end
  end
end
