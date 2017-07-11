# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[5.1]
  def change
    create_table :procedures do |t|
      t.references :person
      t.string :type, null: false
      t.string :state
      t.jsonb :information, null: false, default: {}
      t.references :processed_by, foreign_key: { to_table: :people }
      t.datetime :processed_at
      t.text :comment

      t.timestamps
    end
  end
end
