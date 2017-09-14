# frozen_string_literal: true

module ActiveAdmin::BaseHelper
  def person_flags(person)
    Arbre::Context.new do
      person.flags.map do |flag|
        status_tag I18n.t("census.people.flags.#{flag}"), class: flag
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
end
