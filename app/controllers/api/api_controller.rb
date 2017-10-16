# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_paper_trail_whodunnit

    def person
      unless defined?(@person)
        person_id = params[:participa_id] || params[:id]
        @person = Person.find_by("extra ->> 'participa_id' = ?", person_id) if person_id
      end
      @person
    end

    def user_for_paper_trail
      person
    end
  end
end
