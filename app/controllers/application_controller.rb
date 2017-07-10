# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rectify::ControllerHelpers
  helper TranslationsHelper

  before_action :set_paper_trail_whodunnit

  def current_user
    Person.first
  end
end
