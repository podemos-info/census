# frozen_string_literal: true

# This migration creates the `bics` table.
class CreateBics < ActiveRecord::Migration[5.1]
  def change
    create_table :bics do |t|
      t.string :country, null: false
      t.string :bank_code, null: false
      t.string :bic, null: false
    end

    add_index :bics, [:country, :bank_code], unique: true
  end
end
