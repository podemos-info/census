# frozen_string_literal: true

class VersionDecorator < ApplicationDecorator
  delegate_all

  decorates_association :item
  decorates_association :actor

  IGNORE_FIELD_CHANGES = %w(updated_at).freeze

  def name
    description
  end

  alias to_s name
  alias listable_name name

  def description
    item_class = object.item_type.constantize
    item_class_name = item_class.model_name.human
    if !object.update?
      I18n.t("paper_trail.events.#{object.event}", model: item_class_name)
    else
      changes = object.object_changes.keys - IGNORE_FIELD_CHANGES
      if changes.count <= 3
        changes_list = changes.map { |field| item_class.human_attribute_name(field).downcase }
        I18n.t("paper_trail.events.update_of_list", model: item_class_name, list: changes_list.to_sentence)
      else
        I18n.t("paper_trail.events.update_of_number", model: item_class_name, number: changes.count)
      end
    end .capitalize
  end

  def author
    @author ||= actor ? h.link_to(actor.name, actor) : I18n.t("paper_trail.unknown_author")
  end

  def build_path(association_chain)
    h.url_for association_chain + [object]
  end

  def before
    object.item_type.constantize.new(object.object).decorate
  end

  def after
    @after = before
    object.object_changes.each do |key, values|
      @after[key] = values.last
    end
    @after.decorate
  end

  def item_route_key
    item.respond_to?(:route_key) ? item.route_key : object.item.class.name.underscore.pluralize
  end

  def before_classed_changeset
    classed_changeset(resource.object_changes.keys, "version_change old_value")
  end

  def after_classed_changeset
    classed_changeset(resource.object_changes.keys, "version_change new_value")
  end
end
