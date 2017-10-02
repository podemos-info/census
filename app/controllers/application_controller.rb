# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rectify::ControllerHelpers

  helper TranslationsHelper

  before_action :set_paper_trail_whodunnit

  after_action :track_action

  def current_user
    current_admin
  end

  protected

  def track_action
    return unless track_page_view?

    ahoy.track_visit unless current_visit

    f = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    ahoy.track("page_view", f.filter(params.to_unsafe_hash))
  end

  def track_page_view?
    @track_page_view.nil? ? true : @track_page_view
  end

  def do_not_track_page_view
    @track_page_view = false
  end
end
