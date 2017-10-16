# frozen_string_literal: true

class EventDecorator < ApplicationDecorator
  delegate_all

  decorates_association :admin
  decorates_association :visit

  def name
    if object.name == "page_view"
      action = properties["q"] ? "search" : properties["action"]
      controller = properties["controller"].singularize
      controller_text = I18n.t("activerecord.models.#{controller}", count: properties["id"] ? 1 : 10, default: nil)
      controller_text ||= I18n.t("census.events.controller.#{controller}")

      params = { controller: controller_text, action: I18n.t("census.events.action.#{action}") }
    else
      params = properties.deep_symbolize_keys
    end
    I18n.t("census.events.type.#{object.name}", params).capitalize
  end

  def description
    if properties["id"]
      event_object = controller_model.find_by(id: properties["id"])
      if event_object
        h.link_to event_object.decorate.name, event_object
      else
        properties["id"].to_s
      end
    elsif properties["q"]
      ActiveAdmin::Filters::Active.new(controller_class, controller_model.ransack(properties["q"])).filters.flat_map do |filter|
        filter.condition.attributes.flat_map do |attribute|
          "#{controller_model.human_attribute_name(attribute.name)} #{filter.predicate_name} '#{filter.values.first}'"
        end
      end .to_sentence.capitalize
    else
      ""
    end
  end

  private

  def controller_class
    "#{properties["controller"]}_controller".classify&.constantize
  end

  def controller_model
    properties["controller"]&.classify&.constantize
  end
end
