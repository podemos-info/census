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
      render(json: {}, status: :not_found) && return unless person_at
      render json: person_at, **show_params.to_h.symbolize_keys
    end

    def permitted_params
      ret = params
      ret[:person] = ret.require(:person).except(:scope_id, :address_scope_id, :document_scope_id) if ret[:person]
      ret
    end

    private

    def qualified_id_param
      :id
    end

    def person_at
      @person_at ||= version_at ? person.paper_trail.version_at(version_at) : person
    end

    def version_at
      @version_at ||= Time.zone.parse(params[:version_at]) if params[:version_at]
    end

    def show_params
      params.permit(includes: [], excludes: [])
    end
  end
end
