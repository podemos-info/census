# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    if api_request?
      do_not_track_page_view
      render json: {}, status: :not_found
    else
      render html: "404 Not found", status: :not_found
    end
  end

  def exception
    if api_request?
      do_not_track_page_view
      render json: {}, status: :internal_server_error
    else
      render html: "500 Internal Server Error", status: :internal_server_error
    end
  end

  def params
    super.merge full_path: full_path
  end

  private

  def api_request?
    full_path =~ %r{^/api}
  end

  def full_path
    @full_path ||= request.env["ORIGINAL_FULLPATH"]
  end
end
