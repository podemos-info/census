# frozen_string_literal: true

class CreateOrdersBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :orders_batches do |t|
      t.string :description, null: false

      t.references :processed_by, foreign_key: { to_table: :admins }
      t.datetime :processed_at

      t.jsonb :stats, default: {}, null: false

      t.timestamps
    end
  end
end
