# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      form = ::People::PersonForm.from_params(params)
      ::People::CreatePerson.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:error) do
          render json: {}, status: :internal_server_error
        end
        on(:ok) do |info|
          render json: { person: { id: info[:person].id } }, status: :created
        end
      end
    end

    def update
      form = ::People::PersonForm.from_params(params)
      ::People::UpdatePerson.call(form: form) do
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

    def show
      render(json: {}, status: :not_found) && return unless person
      render json: person
    end

    private

    def person_id_param
      :id
    end
  end
end
