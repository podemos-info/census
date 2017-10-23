# frozen_string_literal: true

ActiveAdmin.register Scope do
  before_action :do_not_track_page_view
  menu false

  actions :browse

  collection_action :browse do
    title = params[:title]
    root = Scope.find(params[:root])&.decorate if params[:root]
    context = root ? { root: root.id, title: title } : { title: title }
    if params[:current]
      current = Scope.find(params[:current]).decorate
      scopes = current.children
      parent_scopes = current.part_of_scopes.map(&:decorate)
    else
      current = root
      scopes = current ? root.children : Scope.top_level
      parent_scopes = []
    end
    render :browse, layout: nil, locals: { title: title, root: root, current: current, scopes: scopes.order(name: :asc).decorate, parent_scopes: parent_scopes, context: context }
  end
end
