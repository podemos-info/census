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
    return unless current_admin
    flash.now[:alert] = I18n.t("census.issues.issues_for_resource", issues_links: issues_for_resource.map(&:link_with_name).to_sentence).html_safe if issues_for_resource.any?
  end

  def decorated_current_admin
    @decorated_current_admin ||= current_admin&.decorate
  end

  protected

  def issues_for_resource
    @issues_for_resource ||= if resource.respond_to?(:issues)
                               ::AdminIssues.for(current_admin).merge(::IssuesOpen.for).merge(Draper.undecorate(resource.issues)).decorate
                             else
                               []
                             end
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
