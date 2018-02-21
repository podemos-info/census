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

    def call_command(command_class, form)
      command_class.call(form: form) do
        on(:invalid) do
          render json: form.errors, status: :unprocessable_entity
        end
        on(:error) do
          render json: {}, status: :internal_server_error
        end
        on(:noop) do
          render json: {}, status: :no_content
        end
        on(:ok) do |info|
          result = yield(info) if block_given?
          render json: result || {}, status: :accepted
        end
      end
    end

    def person_id_param
      :person_id
    end
  end
end
