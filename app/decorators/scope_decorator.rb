# frozen_string_literal: true

class ScopeDecorator < ApplicationDecorator
  delegate_all

  decorates_association :parent

  def full_path(parent = nil)
    object.part_of_scopes(parent).map { |scope| helpers.translated_attribute(scope.name) }.reverse.join ", "
  end

  def name
    @name ||= helpers.translated_attribute(object.name)
  end

  def local_path
    @local_path ||= full_path(Scope.local)
  end

  alias to_s name
  alias listable_name name
end
