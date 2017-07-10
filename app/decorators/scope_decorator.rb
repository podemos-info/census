# frozen_string_literal: true

class ScopeDecorator < ApplicationDecorator
  delegate_all

  def show_path(parent = nil)
    object.path(parent).map { |scope| helpers.translated_attribute(scope.name) }.reverse.join ", "
  end
end
