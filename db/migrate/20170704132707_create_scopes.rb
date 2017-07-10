# frozen_string_literal: true

class CreateScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :scopes do |t|
      t.jsonb :name, default: {}, null: false
      t.references :scope_type, foreign_key: true, null: false
      t.references :parent, foreign_key: { to_table: :scopes }
      t.string :code, null: false
      t.integer :part_of, array: true, default: [], null: false
      t.integer :children_count, default: 0, null: false

      t.index :code, unique: true
      t.index :part_of, using: "gin"

      t.timestamps
    end
  end
end
