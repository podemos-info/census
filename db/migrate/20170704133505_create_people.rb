# frozen_string_literal: true

class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name1
      t.string :last_name2
      t.integer :document_type
      t.string :document_id
      t.references :document_scope, foreign_key: { to_table: :scopes }
      t.date :born_at
      t.integer :gender
      t.string :address
      t.references :address_scope, foreign_key: { to_table: :scopes }
      t.string :postal_code
      t.string :email
      t.string :phone

      t.references :scope
      t.string :level
      t.integer :verifications, default: 0, null: false, index: true
      t.integer :flags, default: 0, null: false
      t.jsonb :extra, default: {}, null: false

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
