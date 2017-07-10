# frozen_string_literal: true

module ActiveAdmin::ViewsHelper
  def person_flags(person)
    Arbre::Context.new do
      person.flags.map do |flag|
        status_tag I18n.t("census.people.flags.#{flag}"), class: flag
      end
    end
  end
end
