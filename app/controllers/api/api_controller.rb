# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_paper_trail_whodunnit

    def person
      @person ||= Person.find(params[:person_id])
    end

    def user_for_paper_trail
      person
    end
  end
end
