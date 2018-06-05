# frozen_string_literal: true

class ErrorsController < ActionController::Base
  def not_found
    if api_request?
      render json: {}, status: :not_found
    else
      render html: "404 Not found", status: :not_found
    end
  end

  def exception
    if api_request?
      render json: {}, status: :internal_server_error
    else
      render html: "500 Internal Server Error", status: :internal_server_error
    end
  end

  private

  def api_request?
    request.env["ORIGINAL_FULLPATH"] =~ %r{^/api}
  end
end
