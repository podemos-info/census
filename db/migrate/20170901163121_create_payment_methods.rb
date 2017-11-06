# frozen_string_literal: true

class CreatePaymentMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_methods do |t|
      t.references :person, null: false
      t.string :name, null: false
      t.string :type, null: false
      t.integer :flags, default: 0, null: false

      t.string :payment_processor, null: false
      t.string :response_code
      t.jsonb :information, default: {}, null: false

      t.timestamps
      t.datetime :deleted_at
    end
    add_index :payment_methods, :information, using: :gin
  end
end
