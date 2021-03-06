# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    include SlaveMode

    before_action :set_paper_trail_whodunnit
    around_action :switch_locale

    slave_mode_check do
      if request.get?
        response.status = slave_mode? ? :non_authoritative_information : :ok
      elsif slave_mode?
        render json: {}, status: :conflict
      end
    end

    def switch_locale(&action)
      locale = params[:locale] || I18n.default_locale

      I18n.with_locale(locale, &action)
    end

    def person
      @person ||= Person.qualified_find(params[qualified_id_param]) if params[qualified_id_param]
    end

    def user_for_paper_trail
      person
    end

    def params_with_person
      permitted_params.merge(qualified_id: params[qualified_id_param])
    end

    protected

    def permitted_params
      params
    end

    def call_command(command_class, form)
      command_class.call(form: form, location: location) do
        on(:invalid) do
          render json: form.errors.details, status: :unprocessable_entity
        end
        on(:error) do
          render json: {}, status: :internal_server_error
        end
        on(:noop) do
          render status: :no_content
        end
        on(:ok) do |info|
          result = yield(info) if block_given?
          render json: result || {}, status: :accepted
        end
      end
    end

    def qualified_id_param
      :person_id
    end

    def location
      {
        qualified_id: person&.qualified_id,
        user_agent: request.user_agent,
        ip: request.headers["HTTP_USER_IP"],
        time: Time.current.to_f
      }
    end
  end
end
