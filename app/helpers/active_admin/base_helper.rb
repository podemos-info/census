# frozen_string_literal: true

module ActiveAdmin::BaseHelper
  def model_name(model, count: 1)
    I18n.t("activerecord.models.#{model.to_s.underscore}", count: count)
  end

  def model_flags(model)
    Arbre::Context.new do
      model.flags.map do |flag|
        status_tag I18n.t("census.#{model.model_name.plural}.flags.#{flag}"), class: flag
      end
    end
  end

  def state_name(model, column, state)
    I18n.t("activerecord.attributes.#{model.to_s.underscore}.#{column}/#{state}")
  end

  def show_table(context:, resource:, title:, table:)
    context.panel(title) do
      context.attributes_table_for resource do
        table.to_a.each do |key, value|
          context.row(key) { value }
        end
      end
    end
  end

  def issues_icons(issuable, context:)
    statuses = %w(fixed gone closed)
    issuable.issues.each do |issue|
      class_name = statuses.lazy.map { |status| status if issue.send(status + "?") }.detect(&:present?)
      context.span class: "issue_icon #{class_name}"
    end
    nil
  end
end
