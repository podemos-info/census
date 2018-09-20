# frozen_string_literal: true

class AddMetadataToScopes < ActiveRecord::Migration[5.2]
  def change
    change_table :scopes, bulk: true do |t|
      t.jsonb :mappings, default: {}, null: false
      t.jsonb :metadata, default: {}, null: false
    end
  end
end
