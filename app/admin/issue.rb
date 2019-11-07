# frozen_string_literal: true

ActiveAdmin.register Issue do
  decorate_with IssueDecorator

  menu parent: :dashboard

  actions :index, :show, :edit, :update

  permit_params do
    resource.fix_attributes
  end

  scope(:unread, default: true) { |scope| AdminUnreadIssues.for(current_admin).merge(IssuesOpen.for).merge(scope) }
  scope(:open) { |scope| AdminIssues.for(current_admin).merge(IssuesOpen.for).merge(scope) }
  scope(:assigned) { |scope| AdminAssignedIssues.for(current_admin).merge(IssuesOpen.for).merge(scope) }
  scope(:closed) { |scope| AdminIssues.for(current_admin).merge(IssuesClosed.for).merge(scope) }

  config.sort_order = "created_at_desc"

  index do
    column :issue_type_name, class: :left, sortable: :issue_type, &:link_with_name
    column :level_name
    column :objects_links
    column :assigned_to
    column :status do |issue|
      status_tag(issue.status_name, class: issue.status)
    end
    column :date do |issue|
      issue.closed_at || issue.created_at
    end
    actions defaults: false, &:link
  end

  show do
    panel t("census.issues.title") do
      render "show"
    end

    show_table context: self, resource: resource, title: t("census.issues.information"), table: resource.information
    show_table context: self, resource: resource, title: t("census.issues.fix_information"), table: resource.fix_information
  end

  form title: I18n.t("census.issues.close.action"), decorate: true do |f|
    render "issues/#{resource.issue_type}/form", context: self, f: f, issue: resource
  end
  sidebar :issue, partial: "issues/show", only: :edit

  action_item :assign_me, only: :show do
    next unless policy(resource).assign_me?

    unless resource.closed? || resource.assigned_to_id == current_admin.person_id
      link_to t("census.issues.assign_me"), assign_me_issue_path, method: :patch, data: { confirm: t("census.messages.sure_question") }
    end
  end

  member_action :assign_me, method: :patch do
    Issues::AssignIssue.call(issue: resource, admin: current_admin)
    redirect_back(fallback_location: issues_path)
  end

  controller do
    before_action only: :show do
      Issues::ReadIssue.call(issue: resource, admin: current_admin)
    end

    def edit
      redirect_back(fallback_location: issues_path, error: t("census.issues.action_message.already_closed")) && return if resource.closed?
      super
    end

    def update
      issue = resource
      issue.assign_attributes permitted_params[:issue]

      Issues::FixIssue.call(issue: issue, admin: current_admin) do
        on(:invalid) { render :edit }
        on(:error) do
          flash.now[:error] = t("census.issues.action_message.error")
          render :edit
        end
        on(:ok) do
          flash[:notice] = t("census.issues.action_message.closed")
          redirect_to issue_path(issue)
        end
      end
    end
  end
end
