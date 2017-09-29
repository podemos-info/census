# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    def person
      unless defined?(@person)
        person_id = params[:participa_id] || params[:id]
        @person = Person.find_by("extra ->> 'participa_id' = ?", person_id) if person_id
      end
      @person
    end

    def current_user
      person
    end
  end
end
