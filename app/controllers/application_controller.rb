# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rectify::ControllerHelpers
  include Pundit
  protect_from_forgery with: :exception

  helper TranslationsHelper

  before_action :set_paper_trail_whodunnit
  before_action :check_resource_issues, only: [:show, :edit]

  after_action :track_action

  def edit; end

  def show; end

  def user_for_paper_trail
    current_admin
  end

  def pundit_user
    current_admin
  end

  def check_resource_issues
    issues = issues_for_resource
    flash.now[:alert] = I18n.t("census.issues.issues_for_resource", issues_links: issues.map(&:link).to_sentence).html_safe if issues.any?
  end

  protected

  def issues_for_resource
    return [] unless resource.respond_to?(:issues)
    @issues_for_resource ||= ::AdminIssues.for(current_admin).merge(::IssuesNonFixed.for).merge(resource.issues).decorate
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
