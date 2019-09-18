# frozen_string_literal: true

class ScopeSerializer < ActiveModel::Serializer
  attributes :id, :name, :scope_type, :code, :mappings

  def scope_type
    object.scope_type.name
  end
end
