# frozen_string_literal: true

module ActiveAdmin::BaseHelper
  def model_flags(model)
    Arbre::Context.new do
      model.flags.map do |flag|
        status_tag I18n.t("census.#{model.model_name.plural}.flags.#{flag}"), class: flag
      end
    end
  end

  def show_table(context, title, table)
    context.attributes_table title: title do
      table.to_a.each do |key, value|
        context.row(key) { value }
      end
    end
  end

  def classed_changeset(version, classes)
    return {} unless version&.event == "update"
    Hash[version.object_changes.keys.map { |field| [field.to_sym, classes] }]
  end
end
