# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      call_command(::People::CreateRegistration, ::People::RegistrationForm.from_params(params_with_person)) do |info|
        { person_id: info[:person].id }
      end
    end

    def update
      call_command ::People::CreatePersonDataChange, ::People::PersonDataChangeForm.from_params(params_with_person)
    end

    def destroy
      call_command ::People::CreateCancellation, ::People::CancellationForm.from_params(params_with_person)
    end

    def show
      render(json: {}, status: :not_found) && return unless person
      render json: person
    end

    private

    def qualified_id_param
      :id
    end
  end
end
