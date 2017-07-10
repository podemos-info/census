# frozen_string_literal: true

class CreateScopeTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :scope_types do |t|
      t.jsonb :name, default: {}, null: false
      t.jsonb :plural, default: {}, null: false

      t.timestamps
    end
  end
end
