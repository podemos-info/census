# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :person, null: false
      t.references :payment_method, null: false
      t.references :orders_batch

      t.string :currency, null: false
      t.integer :amount, null: false

      t.string :description, null: false

      t.references :processed_by, foreign_key: { to_table: :admins }
      t.datetime :processed_at

      t.string :state
      t.jsonb :information, default: {}, null: false
      t.timestamps
    end
  end
end
