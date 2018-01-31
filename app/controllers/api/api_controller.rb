# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_paper_trail_whodunnit

    def person
      @person ||= Person.find_by(id: params[person_id_param]) if params[person_id_param]
    end

    def user_for_paper_trail
      person
    end

    protected

    def person_id_param
      :person_id
    end
  end
end
