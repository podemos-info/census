# frozen_string_literal: true

class ScopeDecorator < ApplicationDecorator
  delegate_all

  decorates_association :parent

  def show_path(parent = nil)
    object.part_of_scopes(parent).map { |scope| helpers.translated_attribute(scope.name) }.reverse.join ", "
  end

  def name
    helpers.translated_attribute(object.name)
  end
end
