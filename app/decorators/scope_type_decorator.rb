# frozen_string_literal: true

class ScopeTypeDecorator < ApplicationDecorator
  delegate_all

  def name
    helpers.translated_attribute(scope_type.name)
  end
end
