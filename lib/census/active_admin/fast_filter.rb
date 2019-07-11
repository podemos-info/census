# frozen_string_literal: true

InheritedResources::BaseHelpers.module_eval do
  alias_method :old_end_of_association_chain, :end_of_association_chain

  def end_of_association_chain
    if fast_filterable? && params[:ff].present?
      old_end_of_association_chain.fast_filter(params[:ff])
    else
      old_end_of_association_chain
    end
  end

  def fast_filterable?
    resource_class.respond_to?(:fast_filter)
  end
end

ActiveAdmin::Views::TitleBar.class_eval do
  alias_method :old_build_titlebar_left, :build_titlebar_left

  def build_titlebar_left
    old_build_titlebar_left
    build_fast_filter
  end

  def build_fast_filter
    return unless controller.fast_filterable?

    div id: "titlebar_fastfilter" do
      form method: :get do
        request.GET.each do |key, value|
          input(type: :hidden, name: key, value: value) if value.present? && key != "ff"
        end

        div id: "searchbox" do
          span icon(:fas, :search, id: "searchicon")
          input type: :text, id: "searchinput", name: :ff, placeholder: I18n.t("census.fast_filter.placeholder"), value: params[:ff], "data-value" => params[:ff]
          para I18n.t("census.fast_filter.update_results", icon: icon(:fas, "level-down-alt", class: "rotate90")).html_safe, class: 'tip'
        end
      end
    end
  end
end