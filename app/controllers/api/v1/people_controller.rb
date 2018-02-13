# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      call_procedure(::People::CreateRegistration, ::People::RegistrationForm.from_params(params)) do |info|
        { person: { id: info[:person].id } }
      end
    end

    def update
      call_procedure ::People::CreatePersonDataChange, ::People::PersonDataChangeForm.from_params(params_with_person_id)
    end

    def destroy
      call_procedure ::People::CreateCancellation, ::People::CancellationForm.from_params(params_with_person_id)
    end

    def show
      render(json: {}, status: :not_found) && return unless person
      render json: person
    end

    private

    def person_id_param
      :id
    end

    def params_with_person_id
      params.merge(person_id: params[:id])
    end
  end
end
