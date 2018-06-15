# frozen_string_literal: true

class AddMetadataToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :scopes, :mappings, :jsonb, default: {}, null: false
    add_column :scopes, :metadata, :jsonb, default: {}, null: false
  end
end
