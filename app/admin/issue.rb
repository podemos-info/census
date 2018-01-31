# frozen_string_literal: true

ActiveAdmin.register Issue do
  decorate_with IssueDecorator

  menu parent: :dashboard

  actions :index, :show

  scope(:unread, default: true) { |scope| AdminUnreadIssues.for(current_admin).merge(scope) }
  scope(:assigned) { |scope| AdminAssignedIssues.for(current_admin).merge(scope) }
  scope(:non_fixed) { |scope| AdminIssues.for(current_admin).merge(IssuesNonFixed.for).merge(scope) }
  scope(:fixed) { |scope| AdminIssues.for(current_admin).merge(IssuesFixed.for).merge(scope) }

  index do
    column :issue_type_name, class: :left do |issue|
      link_to issue.issue_type_name, issue_path(id: issue.id)
    end
    column :level_name
    column :objects_links
    column :assigned_to
    actions
  end

  show do
    attributes_table do
      row :issue_type_name
      row :description
      row :objects_links
      row :role_name
      row :level_name
      row :assigned_to
      row :created_at
      row :updated_at
      row :fixed_at
    end

    show_table context: self, title: t("census.issues.information"), table: resource.information
  end

  action_item :assign_me, only: :show do
    unless resource.fixed_at || resource.assigned_to_id == current_admin.person_id
      link_to t("census.issues.assign_me"), assign_me_issue_path, method: :patch, data: { confirm: t("census.sure_question") }
    end
  end

  action_item :mark_as_fixed, only: :show do
    link_to t("census.issues.mark_as_fixed"), mark_as_fixed_issue_path, method: :patch, data: { confirm: t("census.sure_question") } unless resource.fixed_at
  end

  member_action :assign_me, method: :patch do
    Issues::AssignIssue.call(issue: resource, admin: current_admin)
    redirect_back(fallback_location: issues_path)
  end

  member_action :mark_as_fixed, method: :patch do
    Issues::FixedIssue.call(issue: resource, admin: current_admin)
    redirect_back(fallback_location: issues_path)
  end

  controller do
    before_action only: :show do
      Issues::ReadIssue.call(issue: resource, admin: current_admin)
    end
  end
end
