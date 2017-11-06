# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rectify::ControllerHelpers
  include Pundit
  protect_from_forgery with: :exception

  helper TranslationsHelper

  before_action :set_paper_trail_whodunnit
  before_action :check_resource_issues, only: :show

  after_action :track_action

  def user_for_paper_trail
    current_admin
  end

  def pundit_user
    current_admin
  end

  def check_resource_issues
    issue = issue_for_resource
    flash.now[:alert] = I18n.t("census.issues.issues_for_resource", resource_path: url_for(issue)).html_safe if issue
  end

  protected

  def issue_for_resource
    return unless resource.respond_to?(:issues)
    AdminIssues.for(current_admin).merge(IssuesNonFixed.for).merge(resource.issues).first
  end

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
