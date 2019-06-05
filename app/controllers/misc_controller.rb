# frozen_string_literal: true

class MiscController < ActionController::API
  def csp_report
    body = request.body.read
    begin
      info = ActiveSupport::JSON.decode(body)
    rescue ActiveSupport::JSON.parse_error => _e
      info = { body: body }
    end
    ahoy.track "security_report", info
  end
end
